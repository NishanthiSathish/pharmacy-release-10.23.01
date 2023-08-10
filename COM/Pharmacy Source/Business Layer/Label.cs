//===========================================================================
//
//							        Supplier.cs
//
//  This class holds all business logic for label object data.
//
//	Modification History:
//	31Jul09 XN  Written
//  12Apr12 AJK 31015 Added new fields. 
//  18Feb13 XN  Added field LastSavedDateTime (replaces LastDate) 40210
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>Label business object</summary>
    public class LabelObject : IBusinessObject
    {
        public int       RequestID                   { get; internal set; }
        public string    SisCode                     { get; internal set; }
        public int?      ContainerSize               { get; internal set; }
        public string    IssType                     { get; internal set; }
        public bool      ManualQuantity              { get; internal set; }
        public bool      PRN                         { get; internal set; }
        public bool      PatientsOwn                 { get; internal set; }
        public string    RepeatUnits                 { get; internal set; }
        public bool?     Day1Mon                     { get; internal set; }
        public bool?     Day2Tue                     { get; internal set; }
        public bool?     Day3Wed                     { get; internal set; }
        public bool?     Day4Thu                     { get; internal set; }
        public bool?     Day5Fri                     { get; internal set; }
        public bool?     Day6Sat                     { get; internal set; }
        public bool?     Day7Sun                     { get; internal set; }
        public double    Dose1                       { get; internal set; }
        public double    Dose2                       { get; internal set; }
        public double    Dose3                       { get; internal set; }
        public double    Dose4                       { get; internal set; }
        public double    Dose5                       { get; internal set; }
        public double    Dose6                       { get; internal set; }
        public string    Times1                      { get; internal set; }
        public string    Times2                      { get; internal set; }
        public string    Times3                      { get; internal set; }
        public string    Times4                      { get; internal set; }
        public string    Times5                      { get; internal set; }
        public string    Times6                      { get; internal set; }
        public int       SiteID                      { get; internal set; }
        public string    Text                        { get; internal set; }
        public string    WardCode                    { get; internal set; } // 12Apr12 AJK 31015 Added
        public string    ConsCode                    { get; internal set; } // 12Apr12 AJK 31015 Added
        public string    DispID                      { get; internal set; } // 12Apr12 AJK 31015 Added
        public DateTime? LastDate                    { get; internal set; } // 12Apr12 AJK 31015 Added
        public DateTime? LastSavedDateTime           { get; internal set; } // 18Feb13 XN  40210 Added
        public decimal?  LastQty                     { get; internal set; } // 12Apr12 AJK 31015 Added
        public bool?     PSO                         { get; internal set; } // 13Mar13 TH  58703 Added

        /// <summary>
        /// Returns the prescription description that goes with the label
        /// This is read from the parent request's description.
        /// </summary>
        /// <returns>prescription description</returns>
        public string GetPrescriptionsDescription()
        {
            // Load in the request information
            Request request = new Request();
            request.LoadByRequestID(RequestID);

            // Get the parent request
            Request parentRequest = new Request();
            if (request.Any())
                parentRequest.LoadByRequestID(request[0].RequestID_Parent);

            // Now get the parent request description
            if (parentRequest.Any())
                return parentRequest[0].Description;
            else
                return string.Empty;
        }
    }


    /// <summary>Label business processor</summary>
    public class LabelProcessor : BusinessProcess
    {
        /// <summary>
        /// Loads the label by request ID (or null if the label does not exist)
        /// </summary>
        /// <param name="requestID">Request ID</param>
        /// <returns>Lable with the speficied request ID</returns>
        public LabelObject LoadByRequestID ( int requestID )
        {
            WLabel dblabel = new WLabel();
            dblabel.LoadByRequestID(requestID);

            if (dblabel.Any())
                return FillData(dblabel[0]);
            else
                return null;
        }

        /// <summary>
        /// Creates a Label object from a db label
        /// </summary>
        /// <param name="dblabelRow">Db label</param>
        /// <returns>Label object</returns>
        private LabelObject FillData (WLabelRow dblabelRow)
        {
            LabelObject label = new LabelObject();

            label.RequestID                 = dblabelRow.RequestID;
            label.SisCode                   = dblabelRow.SisCode;                 
            label.ContainerSize             = dblabelRow.ContainerSize;           
            label.IssType                   = dblabelRow.IssType;                 
            label.ManualQuantity            = dblabelRow.ManualQuantity;          
            label.PRN                       = dblabelRow.PRN;                     
            label.PatientsOwn               = dblabelRow.PatientsOwn;             
            label.RepeatUnits               = dblabelRow.RepeatUnits;             
            label.Day1Mon                   = dblabelRow.Day1Mon;                 
            label.Day2Tue                   = dblabelRow.Day2Tue;                 
            label.Day3Wed                   = dblabelRow.Day3Wed;                 
            label.Day4Thu                   = dblabelRow.Day4Thu;                 
            label.Day5Fri                   = dblabelRow.Day5Fri;                 
            label.Day6Sat                   = dblabelRow.Day6Sat;                 
            label.Day7Sun                   = dblabelRow.Day7Sun;                 
            label.Dose1                     = dblabelRow.Dose1;                   
            label.Dose2                     = dblabelRow.Dose2;                   
            label.Dose3                     = dblabelRow.Dose3;                   
            label.Dose4                     = dblabelRow.Dose4;                   
            label.Dose5                     = dblabelRow.Dose5;                   
            label.Dose6                     = dblabelRow.Dose6;                   
            label.Times1                    = dblabelRow.Times1;                  
            label.Times2                    = dblabelRow.Times2;                  
            label.Times3                    = dblabelRow.Times3;                  
            label.Times4                    = dblabelRow.Times4;                  
            label.Times5                    = dblabelRow.Times5;                  
            label.Times6                    = dblabelRow.Times6;                  
            label.SiteID                    = dblabelRow.SiteID;   
            label.Text                      = dblabelRow.Text;
            label.WardCode                  = dblabelRow.WardCode;  // 12Apr12 AJK 31015 Added
            label.ConsCode                  = dblabelRow.ConsCode; // 12Apr12 AJK 31015 Added
            label.DispID                    = dblabelRow.DispID; // 12Apr12 AJK 31015 Added
            label.LastDate                  = dblabelRow.LastDate; // 12Apr12 AJK 31015 Added
            label.LastSavedDateTime         = dblabelRow.LastSavedDateTime; // 18Feb13 XN  40210 Added
            label.LastQty                   = dblabelRow.LastQty; // 12Apr12 AJK 31015 Added
            label.PSO = dblabelRow.PSO; // 13Mar13 TH  58703 Added
            return label;
        }
    }
}
