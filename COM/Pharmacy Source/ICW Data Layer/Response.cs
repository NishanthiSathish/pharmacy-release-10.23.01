using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    internal class ResponseRow : BaseRow
    {
        public int ResponseID
        {
            get { return FieldToInt(RawRow["ResponseID"]).Value; }
        }

        public int ResponseTypeID
        {
            get { return FieldToInt(RawRow["ResponseTypeID"]).Value; }
            set { RawRow["ResponseTypeID"] = IntToField(value);      }
        }

        public int RequestID
        {
            get { return FieldToInt(RawRow["RequestID"]).Value; }
            set { RawRow["RequestID"] = IntToField(value);      }
        }

        public int TableID
        {
            get { return FieldToInt(RawRow["TableID"]).Value; }
            set { RawRow["TableID"] = IntToField(value);      }
        }

        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
            set { RawRow["EntityID"] = IntToField(value);      }
        }

        public DateTime CreatedDate
        {
            get { return FieldToDateTime(RawRow["CreatedDate"]).Value; }
            set { RawRow["CreatedDate"] = DateTimeToField(value);      }
        }

        public DateTime ResponseDate
        {
            get { return FieldToDateTime(RawRow["ResponseDate"]).Value; }
            set { RawRow["ResponseDate"] = DateTimeToField(value);      }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"]);     }
            set { RawRow["Description"] = StrToField(value);    }
        }

        public string ShortDescription
        {
            get { return FieldToStr(RawRow["ShortDescription"]);     }
            set { RawRow["ShortDescription"] = StrToField(value);    }
        }
    }

    internal class ResponseColumnInfo : BaseColumnInfo
    {
        public ResponseColumnInfo() : base("Response") { }

        public int DescriptionLength       { get { return this.FindColumnByName("Description").Length;      } }
        public int ShortDescriptionLength  { get { return this.FindColumnByName("ShortDescription").Length; } }
    }

    internal class Response : BaseTable2<ResponseRow, ResponseColumnInfo>
    {
        public Response() : base("Response") { }

        public override ResponseRow Add()
        {
            ResponseRow row = base.Add();
            row.CreatedDate = DateTime.Now;
            row.EntityID    = SessionInfo.EntityID;
            return row;
        }
    }
}
