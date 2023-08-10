//===========================================================================
//
//							RDispBatchTemplate.cs
//
//  This class holds all business logic for handling repeat dispensing
//  batch templates.
//
//	Modification History:
//	03May11 AJK  Written
//===========================================================================
using System;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Represents a single repeat dispensing batch template
    /// </summary>
    public class RepeatDispensingBatchTemplateLine : IBusinessObject
    {
        public int      RepeatDispensingBatchTemplateID     { get; set; }
        public string   Description                         { get; set; }
        public int?     LocationID                          { get; set; }
        public string   LocationDescription                 { get; set; }
        public bool     InPatient                           { get; set; }
        public bool     OutPatient                          { get; set; }
        public bool     Discharge                           { get; set; }
        public bool     Leave                               { get; set; }
        public bool     SelectPatientsByDefault             { get; set; }
        public int      BagLabels                           { get; set; }
        public bool     JVM                                 { get; set; }
        public bool?    JVMDefaultStartTomorrow             { get; set; }
        public int?     JVMDuration                         { get; set; }
        public bool?    JVMBreakfast                        { get; set; }
        public bool?    JVMLunch                            { get; set; }
        public bool?    JVMTea                              { get; set; }
        public bool?    JVMNight                            { get; set; }
        public bool?    JVMIncludeManual                    { get; set; }
        public bool?    JVMSortByAdminSlot                  { get; set; }
        public bool     InUse                               { get; set; }
    }

    /// <summary>
    /// Processes repeat dispensing batch template objects
    /// </summary>
    public class RepeatDispensingBatchTemplateProcessor : BusinessProcess
    {
        /// <summary>
        /// Locks the repeat dispensing batch template table
        /// </summary>
        /// <param name="template">Repeat dispensing batch template object to lock</param>
        public void Lock(RepeatDispensingBatchTemplateLine template)
        {
            RepeatDispensingBatchTemplate dbTemplate = new RepeatDispensingBatchTemplate();
            dbTemplate.LoadByRepeatDispensingBatchTemplateID(template.RepeatDispensingBatchTemplateID);
            LockRows(dbTemplate.Table, dbTemplate.TableName, dbTemplate.PKColumnName);
        }
        
        /// <summary>
        /// Copies data from a template data layer object into a RepeatDispensingBatchTemplate business layer object
        /// </summary>
        /// <param name="dbTemplate">TemplateRow from the data layer used for data source</param>
        /// <returns></returns>
        private RepeatDispensingBatchTemplateLine FillData(RepeatDispensingBatchTemplateRow dbTemplate)
        {
            RepeatDispensingBatchTemplateLine template = new RepeatDispensingBatchTemplateLine();
            template.BagLabels = dbTemplate.BagLabels;
            template.Description = dbTemplate.Description;
            template.Discharge = dbTemplate.Discharge;
            template.InPatient = dbTemplate.InPatient;
            template.JVM = dbTemplate.JVM;
            template.JVMBreakfast = dbTemplate.JVMBreakfast;
            template.JVMDefaultStartTomorrow = dbTemplate.JVMDefaultStartTomorrow;
            template.JVMDuration = dbTemplate.JVMDuration;
            template.JVMIncludeManual = dbTemplate.JVMIncludeManual;
            template.JVMLunch = dbTemplate.JVMLunch;
            template.JVMNight = dbTemplate.JVMNight;
            template.JVMSortByAdminSlot = dbTemplate.JVMSortByAdminSlot;
            template.JVMTea = dbTemplate.JVMTea;
            template.Leave = dbTemplate.Leave;
            template.LocationID = dbTemplate.LocationID;
            template.LocationDescription = dbTemplate.LocationDescription;
            template.OutPatient = dbTemplate.OutPatient;
            template.RepeatDispensingBatchTemplateID = dbTemplate.RepeatDispensingBatchTemplateID;
            template.SelectPatientsByDefault = dbTemplate.SelectPatientsByDefault;
            template.InUse = dbTemplate.InUse;
            return template;
        }
        
        /// <summary>
        /// Loads all repeat dispensing batch templates
        /// </summary>
        /// <returns>List of repeat dispensing batch templates</returns>
        public List<RepeatDispensingBatchTemplateLine> LoadAll()
        {
            List<RepeatDispensingBatchTemplateLine> templateList = new List<RepeatDispensingBatchTemplateLine>();
            using (RepeatDispensingBatchTemplate dbTemplate = new RepeatDispensingBatchTemplate())
            {
                dbTemplate.LoadAll();
                for (int i = 0; i < dbTemplate.Count; i++)
                {
                    templateList.Add(FillData(dbTemplate[i]));
                }
            }
            return templateList;
        }

        /// <summary>
        /// Loads all repeat dispensing batch templates which are marked as in-use
        /// </summary>
        /// <returns>List of repeat dispensing batch templates</returns>
        public List<RepeatDispensingBatchTemplateLine> LoadInUse()
        {
            List<RepeatDispensingBatchTemplateLine> templateList = new List<RepeatDispensingBatchTemplateLine>();
            using (RepeatDispensingBatchTemplate dbTemplate = new RepeatDispensingBatchTemplate())
            {
                dbTemplate.LoadInUse();
                for (int i = 0; i < dbTemplate.Count; i++)
                {
                    templateList.Add(FillData(dbTemplate[i]));
                }
            }
            return templateList;
        }

        public RepeatDispensingBatchTemplateLine LoadByTemplateID(int templateID)
        {
            using (RepeatDispensingBatchTemplate dbTemplate = new RepeatDispensingBatchTemplate())
            {
                dbTemplate.LoadByRepeatDispensingBatchTemplateID(templateID);
                if (dbTemplate.Count == 0)
                    throw new ApplicationException(string.Format("Template not found (templateID={0})", templateID));
                return FillData(dbTemplate[0]);
            }
        }

        public List<RepeatDispensingBatchTemplateLine> LoadByDescription(string description)
        {
            List<RepeatDispensingBatchTemplateLine> templateList = new List<RepeatDispensingBatchTemplateLine>();
            using (RepeatDispensingBatchTemplate dbTemplate = new RepeatDispensingBatchTemplate())
            {
                dbTemplate.LoadByDescription(description);
                if (dbTemplate.Count > 1)
                    throw new ApplicationException(string.Format("Multiple templates found with the same description (description={0})", description));
                for (int i = 0; i < dbTemplate.Count; i++)
                {
                    templateList.Add(FillData(dbTemplate[i]));
                }
            }
            return templateList;
        }

        public void Update(RepeatDispensingBatchTemplateLine template)
        {
            using (RepeatDispensingBatchTemplate dbTemplate = new RepeatDispensingBatchTemplate())
            {
                if (template.RepeatDispensingBatchTemplateID == 0)
                {
                    dbTemplate.Add();
                }
                else
                {
                    dbTemplate.LoadByRepeatDispensingBatchTemplateID(template.RepeatDispensingBatchTemplateID);
                }
                dbTemplate[0].BagLabels = template.BagLabels;
                dbTemplate[0].Description = template.Description;
                dbTemplate[0].Discharge = template.Discharge;
                dbTemplate[0].InPatient = template.InPatient;
                dbTemplate[0].InUse = template.InUse;
                dbTemplate[0].JVM = template.JVM;
                dbTemplate[0].JVMBreakfast = template.JVMBreakfast;
                dbTemplate[0].JVMDefaultStartTomorrow = template.JVMDefaultStartTomorrow;
                dbTemplate[0].JVMDuration = template.JVMDuration;
                dbTemplate[0].JVMIncludeManual = template.JVMIncludeManual;
                dbTemplate[0].JVMLunch = template.JVMLunch;
                dbTemplate[0].JVMNight = template.JVMNight;
                dbTemplate[0].JVMSortByAdminSlot = template.JVMSortByAdminSlot;
                dbTemplate[0].JVMTea = template.JVMTea;
                dbTemplate[0].Leave = template.Leave;
                dbTemplate[0].LocationID = template.LocationID;
                dbTemplate[0].OutPatient = template.OutPatient;
                dbTemplate[0].SelectPatientsByDefault = template.SelectPatientsByDefault;
                dbTemplate.Save();
                template.RepeatDispensingBatchTemplateID = dbTemplate[0].RepeatDispensingBatchTemplateID;
            }
        }
    }
}
