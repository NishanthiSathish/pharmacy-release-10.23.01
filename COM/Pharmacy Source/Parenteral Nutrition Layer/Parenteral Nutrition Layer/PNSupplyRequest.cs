//===========================================================================
//
//							    PNSupplyRequest.cs
//
//  Provides access to PNSupplyRequest table.
//  Inherites from SupplyRequest, and Request.
//
//  Supports updating, reading, and inserting.
//
//	Modification History:
//	30Jun09 AJK  Written
//  01Dec11 XN   Added updating, and inserting support.
//  23Jan12 XN   Added GetRequestType() as virtual method, for SupplyRequest
//  16Mar12 XN   Added GetStatus (TFS28157)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public class PNSupplyRequestRow : SupplyRequestRow
    {
        public string BatchNumber
        {
            get { return FieldToStr(RawRow["BatchNumber"]); }
            set { RawRow["BatchNumber"] = StrToField(value); }
        }
        
        public DateTime? AdminStartDate
        {
            get { return FieldToDateTime(RawRow["AdminStartDate"]); }
            set { RawRow["AdminStartDate"] = DateTimeToField(value); }
        }

        public DateTime PreperationDate
        {
            get { return FieldToDateTime(RawRow["PreperationDate"]).Value; }
            set { RawRow["PreperationDate"] = DateTimeToField(value);      }
        }

        /// <summary>Date of exipry of aqueous (or combined) part of regimen</summary>
        public DateTime ExpiryAqueousCombined
        {
            get { return PreperationDate.AddDays(this.ExpiryDaysAqueousCombined); }
        }

        /// <summary>Number of days from preperation date till aqueous (or combined) part will expire</summary>
        public int ExpiryDaysAqueousCombined
        {
            get { return FieldToInt(RawRow["ExpiryDaysAqueousCombined"]).Value; }
            set { RawRow["ExpiryDaysAqueousCombined"] = IntToField(value);      }
        }

        /// <summary>Date of exipry of lipid part of regimen</summary>
        public DateTime? ExpiryLipid
        {
            get { return this.ExpiryDaysLipid.HasValue ? PreperationDate.AddDays(this.ExpiryDaysLipid.Value) : (DateTime?)null; }
        }

        /// <summary>Number of days from preperation date till lipid part will expire</summary>
        public int? ExpiryDaysLipid
        {
            get { return FieldToInt(RawRow["ExpiryDaysLipid"]); }
            set { RawRow["ExpiryDaysLipid"] = IntToField(value); }
        }

        public int? NumberOfLabelsAminoCombined
        {
            get { return FieldToInt(RawRow["NumberOfLabelsAminoCombined"]); }
            set { RawRow["NumberOfLabelsAminoCombined"] = IntToField(value); }
        }

        public int? NumberOfLabelsLipid
        {
            get { return FieldToInt(RawRow["NumberOfLabelsLipid"]); }
            set { RawRow["NumberOfLabelsLipid"] = IntToField(value); }
        }

        public bool? BaxaCompounder
        {
            get { return FieldToBoolean(RawRow["BaxaCompounder"]); }
            set { RawRow["BaxaCompounder"] = BooleanToField(value); }
        }

        public bool? BaxaIncludeLipid
        {
            get { return FieldToBoolean(RawRow["BaxaIncludeLipid"]); }
            set { RawRow["BaxaIncludeLipid"] = BooleanToField(value); }
        }

        /// <summary>If request has been cancelled</summary>
        public bool Cancelled
        {
            get { return FieldToBoolean(RawRow["Request Cancellation"]).Value;   } 
        }

        /// <summary>
        /// Returns if the supply request can be cancelled (with reason why not)
        /// Can't be canceled, if printed, issued, or completed
        /// Though okay to cancel regimen, and hence canel all the supply requests (TFS28157)
        /// </summary>
        /// <param name="reason">If returns false, will be reson can't cancel</param>
        /// <returns>If can cancel</returns>
        public bool CanCancel(out string reason)
        {
            bool canCancel = false;
            reason = string.Empty;

            if (this.GetStatus("PNPrinted"))
                reason = "Can't cancel as printed.";
            else if (this.GetStatus("PNIssued"))
                reason = "Can't cancel as issued.";
            else if (this.IsComplete())
                reason = "Can't cancel as completed.";
            else
                canCancel = true;

            return canCancel;
        }
    }

    public class PNSupplyRequestColumnInfo : SupplyRequestColumnInfo
    {
        public PNSupplyRequestColumnInfo() : base("PNSupplyRequest") { }
    }

    public class PNSupplyRequest : SupplyRequestBaseTable<PNSupplyRequestRow, PNSupplyRequestColumnInfo>
    {
        public PNSupplyRequest() : base("PNSupplyRequest", "SupplyRequest", "EpisodeOrder",  "Request") { }

        public void LoadByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RequestID", requestID));
            LoadBySP("pPNSupplyRequestByRequestID", parameters);
        }

        public static PNSupplyRequestRow GetByRequestID(int requestID)
        {
            PNSupplyRequest request = new PNSupplyRequest();
            request.LoadByRequestID(requestID);
            return request.Any() ? request[0] : null;
        }
    }
}
