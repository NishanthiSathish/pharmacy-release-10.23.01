//===========================================================================
//
//							            Consultant.cs
//
//  These classes hold business logic for handling consultant data.
//
//	Modification History:
//	22Nov11 AJK  Written
//===========================================================================
using System.Collections.Generic;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>Consultant business object</summary>
    public class ConsultantLine : IBusinessObject
    {
        public int EntityID { get; internal set; }
        public string Forename { get; internal set; }
        public string Surname { get; internal set; }
        public string ConsultantCode { get; internal set; }
        public string CustomAlias { get; internal set; }
        public string FullName { get; internal set; }
    }

    /// <summary>Consultant business processor</summary>
    public class ConsultantProcessor : BusinessProcess
    {
        public List<ConsultantLine> LoadAllByAliasGroupDescription(string description)
        {
            List<ConsultantLine> consultants = new List<ConsultantLine>();
            using (Consultant dbConsultant = new Consultant())
            {
                dbConsultant.LoadAllByAliasGroupDescription(description);
                for (int i = 0; i < dbConsultant.Count; i++)
                {
                    consultants.Add(FillData(dbConsultant[i]));
                }
            }
            return consultants;
        }
        
        /// <summary>
        /// Copies data from a consultant data layer object into a consultant business layer object
        /// </summary>
        /// <param name="dbConsultantRow">Consultant row from the data layer used for data source</param>
        /// <returns>Filled consultant object</returns>
        private ConsultantLine FillData(ConsultantRow dbConsuitantRow)
        {
            ConsultantLine consultant = new ConsultantLine();
            consultant.ConsultantCode = dbConsuitantRow.Code;
            consultant.CustomAlias = dbConsuitantRow.CustomAlias;
            consultant.Forename = dbConsuitantRow.Forename;
            consultant.Surname = dbConsuitantRow.Surname;
            consultant.FullName = dbConsuitantRow.Description;
            consultant.EntityID = dbConsuitantRow.EntityID;
            return consultant;
        }

    }
}
