//===========================================================================
//
//					         PNPrintProcessor.cs
//
//  This class holds all business logic for Parenteral Nutrition printing
//
//  The methods will return all the print data in a large string of xml
//  where the node name is the print element, and the node value is the print data.
// 
//  e.g.
//  <PNPrintData>
//      <patname>Bob Test</patname>
//      <dob>10/06/1989</dob>
//      <caseno>47374626322</caseno>
//      :
//      :
//  </PNPrintData>
//
//  This data is then sent to client side printing which parse it through the print layouts
//
//  Any print element names that contain invalid xml node name chars these will be replaced with '_'
//  e.g. print element totml/kg will be <totml_kg></totml_kg>
//
//  It is possible for a site to has custom print data by adding a site specific SP pSiteSpecificRxPrinting
//  Has parameters CurrentSessionID, SiteID, RequestID_Prescriptionand and returns single row where column name is print tag.
//  Note that pSiteSpecificRxPrinting is used by the client as well for core dispensing
//  
//  Usage:
//  PNPrintProcessor.GetPrintXMLFromSupplyRequest(32321);
//
//	Modification History:
//	20Mar12 XN  Written
//  25Mar12 XN  TFS29994 Short regimen name is now just 'Modification x'
//  11Feb13 XN  Fixed issue with missing SpGrv causing subscript out of range 
//              error to vb6 code
//  11Sep14 XN  88799 Replace GetPrintXML with GetPrintXMLFromRegimen, 
//              GetPrintXMLFromSupplyRequest so split the print functions out
//              Also made everything static
//  18Sep14 XN  30679 Added print items regimen30, regimennomodtext, 
//              regimennomodtext30, modtextshort
//  25Sep15 XN  130083 incorrect calculation of overage for combined regimen
//  24Sep15 XN Fixed type in PNPrescritpionColumnInfo 77778
//  28Sep15 XN Removed printing from alias and added printing from an sp (WriteSiteSpecificPrinting)
//  01Oct15 XN WriteSiteSpecificPrinting added converting Chinese name to RTF image 130210
//  03Oct15 XN If no Chinese name then print English name 133949
//  02Jun16 XN 154627 WriteRegimen Fix the infusion rate to display correct rounding 
//===========================================================================
namespace ascribe.pharmacy.parenteralnutritionlayer
{
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml;

using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.reportlayer;

    /// <summary>Used to create xml string of PN print elements and values</summary>
    public class PNPrintProcessor
    {
        /// <summary>Create PN print XML from regimen request  11Sep14 XN  88799</summary>
        public static string GetPrintXMLFromRegimen(int requestID_Regimen)
        {
            StringBuilder xml = new StringBuilder();

            // Load data
            PNRegimen regimens = new PNRegimen();
            regimens.LoadByRequestID(requestID_Regimen);
            if (!regimens.Any())
                throw new ApplicationException(string.Format("Invalid PN regimen requestID {0}", requestID_Regimen));

            PNProcessor processor = new PNProcessor();
            processor.Initalise(regimens, regimens[0].GetRegimenItems());

            PNPrescriptionRow     prescription = processor.Prescription;
            EpisodeRow            episode      = processor.Episode;
            PatientRow            patient      = processor.Patient;
            WardRow               patientWard  = episode.GetWard();
            PersonRow             prescriber   = Person.GetByEntityID(prescription.EntityID_Owner);
            ConsultantRow         consultant   = episode.GetConsultant();

            // Start xml doc
            XmlWriterSettings xmlSettings = new XmlWriterSettings();
            xmlSettings.OmitXmlDeclaration = true;
            xmlSettings.Indent = true;

            using (XmlWriter xmlWriter = XmlWriter.Create(xml, xmlSettings))
            {
                // Create root node
                xmlWriter.WriteStartElement("PNPrintData");

                WritePrescription(xmlWriter, prescription    );
                WritePatient     (xmlWriter, patient, episode);
                WritePrescriber  (xmlWriter, prescriber      );
                WriteWard        (xmlWriter, patientWard     );
                WriteConsultant  (xmlWriter, consultant      );
                WriteRegimen     (xmlWriter, processor       );
                WriteSiteSpecificPrinting(xmlWriter, prescription, processor.Regimen);        // 28Sep15 XN 77778 Added

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>Create PN print XML from supply request  11Sep14 XN  88799</summary>
        public static string GetPrintXMLFromSupplyRequest(int requestID_SupplyRequest)
        {
            StringBuilder xml = new StringBuilder();

            PNSupplyRequestRow supply = PNSupplyRequest.GetByRequestID(requestID_SupplyRequest);
            if (supply == null)            
                throw new ApplicationException(string.Format("Invalid PN supply requestID {0}", requestID_SupplyRequest));            
            
            // Load data
            PNRegimen regimens = new PNRegimen();
            regimens.LoadByRequestID(supply.RequestID_Parent);

            PNProcessor processor = new PNProcessor();
            processor.Initalise(regimens, regimens[0].GetRegimenItems());

            PNPrescriptionRow     prescription = processor.Prescription;
            EpisodeRow            episode      = processor.Episode;
            PatientRow            patient      = processor.Patient;
            WardRow               patientWard  = episode.GetWard();
            PersonRow             prescriber   = Person.GetByEntityID(prescription.EntityID_Owner);
            ConsultantRow         consultant   = episode.GetConsultant();

            // Start xml doc
            XmlWriterSettings xmlSettings = new XmlWriterSettings();
            xmlSettings.OmitXmlDeclaration = true;
            xmlSettings.Indent = true;

            using (XmlWriter xmlWriter = XmlWriter.Create(xml, xmlSettings))
            {
                // Create root node
                xmlWriter.WriteStartElement("PNPrintData");

                WritePrescription   (xmlWriter, prescription             );
                WritePatient        (xmlWriter, patient, episode         );
                WritePrescriber     (xmlWriter, prescriber               );
                WriteWard           (xmlWriter, patientWard              );
                WriteConsultant     (xmlWriter, consultant               );
                WriteRegimen        (xmlWriter, processor                );
                WriteSupplyRequest  (xmlWriter, supply, processor.Regimen);
                WriteSiteSpecificPrinting(xmlWriter, prescription, processor.Regimen);// 28Sep15 XN 77778 Added

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>Create PN print XML for patient information  11Sep14 XN  88799</summary>
        private static void WritePatient(XmlWriter xmlWriter, PatientRow patient, EpisodeRow episode)
        {
            WriteValue(xmlWriter, "patname",    string.Format("{0} {1}", patient.Forename, patient.Surname).Trim().FixedWidthPadRight(36));
            WriteValue(xmlWriter, "patname21",  BuildName(patient));
            WriteValue(xmlWriter, "dob",        patient.DOB.ToPharmacyDateString().FixedWidthPadRight(15));
            WriteValue(xmlWriter, "caseno",     patient.GetCaseNumber() ?? string.Empty);
            WriteValue(xmlWriter, "pnhnumber",  (patient.GetNHSNumber() ?? string.Empty).Replace("INVALID", string.Empty).Replace("VALID", string.Empty));
            
            // Added for Hope, in/out patient headers
            WriteValue(xmlWriter, "i/olblhdr", (episode.EpisodeType == EpisodeType.OutPatient) ? "[opLblHdr]" : "[ipLblHdr]");
        }

        /// <summary>Create PN print XML for ward information  11Sep14 XN  88799</summary>
        private static void WriteWard(XmlWriter xmlWriter, WardRow ward)
        {
            WriteValue(xmlWriter, "wardexp",    (ward  == null) ? string.Empty : ward.ToString());
            WriteValue(xmlWriter, "wardexp20",  ((ward == null) ? string.Empty : ward.ToString()).FixedWidthPadRight(20));
        }

        /// <summary>Create PN print XML for prescriber information  11Sep14 XN  88799</summary>
        private static void WritePrescriber(XmlWriter xmlWriter, PersonRow prescriber)
        {
            WriteValue(xmlWriter, "reqdoc", prescriber.Description);
        }

        /// <summary>Create PN print XML for consultant information  11Sep14 XN  88799</summary>
        private static void WriteConsultant(XmlWriter xmlWriter, ConsultantRow consultant)
        {
            WriteValue(xmlWriter, "consexp",    (consultant   == null) ? string.Empty : consultant.Description.FixedWidthPadRight(30)); // TFS31219 5Apr12 XN Check if consultant present before printing
            WriteValue(xmlWriter, "consexp15",  (consultant   == null) ? string.Empty : consultant.Description.FixedWidthPadRight(15));
        }

        /// <summary>Create PN print XML for prescription information  11Sep14 XN  88799</summary>
        private static void WritePrescription(XmlWriter xmlWriter, PNPrescriptionRow prescription)
        {
            string temp;

            WriteValue(xmlWriter, "doseweight", prescription.DosingWeightInkg.ToString("0.##kg"));  // Added beter doseweight tag (as some print outs have this
            WriteValue(xmlWriter, "weight",     prescription.DosingWeightInkg.ToString("0.##kg"));
            WriteValue(xmlWriter, "PNbegdate",  prescription.RequestDate.ToPharmacyDateString());

            temp = prescription.GetFreeTextDirection();
            WriteValue(xmlWriter, "comment",    StringExtensions.IsNullOrEmptyAfterTrim(temp) ? string.Empty : "[commentlin]");
            WriteValue(xmlWriter, "commenttxt", temp);

            WriteValue(xmlWriter, "pharmacytext", prescription.GetDispensingInstruction());
        }

        /// <summary>Create PN print XML for regimen information  11Sep14 XN  88799</summary>
        private static void WriteRegimen( XmlWriter xmlWriter, PNProcessor processor)
        {
            PNRegimenRow          regimen      = processor.Regimen;
            PNPrescriptionRow     prescription = processor.Prescription;
            PersonRow             prescriber   = Person.GetByEntityID(prescription.EntityID_Owner);
            List<PNIngredientRow> ingredients  = PNIngredient.GetInstance().FindByForViewAdjust().OrderBySortIndex().ToList();

            bool adult = (prescription.AgeRage == AgeRangeType.Adult);
            double adultPeadWeightDiv  = adult ? 1.0          : prescription.DosingWeightInkg;
            string adultPeadUnitDivStr = adult ? string.Empty : "/kg";
            string temp;

            List<PNRegimenItem> aqueousOrCombinedItems = processor.RegimenItems.FindByAqueousOrLipid(regimen.IsCombined ? PNProductType.Combined : PNProductType.Aqueous).OrderBySortIndex().ToList();
            List<PNRegimenItem> aqueousOnlyItems       = processor.RegimenItems.FindByAqueousOrLipid(PNProductType.Aqueous).OrderBySortIndex().ToList();
            List<PNRegimenItem> lipidOnlyItems         = processor.RegimenItems.FindByAqueousOrLipid(PNProductType.Lipid  ).OrderBySortIndex().ToList();

            WriteValue(xmlWriter, "regimen",           regimen.Description);
            WriteValue(xmlWriter, "regimen30",         regimen.Description.Trim().FixedWidthPadRight(30));          // 18Sep14 XN 30679 Added
            WriteValue(xmlWriter, "regimennomodtext",  regimen.ExtractBaseName());                                  // 18Sep14 XN 30679 Added
            WriteValue(xmlWriter, "regimennomodtext30",regimen.ExtractBaseName().Trim().FixedWidthPadRight(30));    // 18Sep14 XN 30679 Added
            WriteValue(xmlWriter, "regname",           (regimen.ModificationNumber > 0) ? string.Format("Modification {0}", regimen.ModificationNumber) : string.Empty); // TFS29994 XN 25Mar12 Short regimen name is now just 'Modification x'
            WriteValue(xmlWriter, "modtextshort",      (regimen.ModificationNumber > 0) ? string.Format("Mod {0}",          regimen.ModificationNumber) : string.Empty); // 18Sep14 XN 30679 Added

            double totalVolume = processor.RegimenItems.CalculateTotal(PNIngDBNames.Volume);
            double totalAqueousOrCombined = aqueousOrCombinedItems.CalculateTotal(PNIngDBNames.Volume);
            double totalAmino = aqueousOnlyItems.CalculateTotal(PNIngDBNames.Volume);
            double totalLipid = lipidOnlyItems.CalculateTotal(PNIngDBNames.Volume);
            double supplyMultiplier = regimen.SupplyMultiplier;

            xmlWriter.WriteStartElement("wsmixigs");
            if (adult)
            {
                WriteWorksheetTable(xmlWriter, aqueousOrCombinedItems.OrderBySortIndex(), "AWS-A", processor, totalAqueousOrCombined, supplyMultiplier);
                if (!regimen.IsCombined)
                    WriteWorksheetTable(xmlWriter, lipidOnlyItems.OrderBySortIndex(), "AWS-L", processor, totalLipid, supplyMultiplier);
            }
            else
                xmlWriter.WriteValue("** INCORRECT USE OF WORKSHEET KEYWORD: wsmixigs");
            xmlWriter.WriteEndElement();

            // Volume and weights for peads
            xmlWriter.WriteStartElement("wsmix_kg");    // wsmix/kg  in document
            if (!adult)
            {
                WriteWorksheetTable(xmlWriter, aqueousOrCombinedItems.OrderBySortIndex(), "PWS-A", processor, totalAqueousOrCombined, supplyMultiplier);
                if (!regimen.IsCombined)
                    WriteWorksheetTable(xmlWriter, lipidOnlyItems.OrderBySortIndex(), "PWS-L", processor, totalLipid, supplyMultiplier);
            }
            else
                xmlWriter.WriteValue("** INCORRECT USE OF WORKSHEET KEYWORD: wsmix/kg");
            xmlWriter.WriteEndElement();

            // Constituents
            WriteConstituents(xmlWriter, "constits",   processor.RegimenItems,  true,               false,   prescription.DosingWeightInkg);
            WriteConstituents(xmlWriter, "constitsa",  aqueousOrCombinedItems,  regimen.IsCombined, false,   prescription.DosingWeightInkg);
            WriteConstituents(xmlWriter, "constitsb",  lipidOnlyItems,          true,               false,   prescription.DosingWeightInkg);
            WriteConstituents(xmlWriter, "constitskg", processor.RegimenItems,  regimen.IsCombined, true,    prescription.DosingWeightInkg);
            WriteConstituents(xmlWriter, "constkgtot", processor.RegimenItems,  true,               true,    prescription.DosingWeightInkg);

            // Ingredients
            for (int x = 0; x < ingredients.Count; x++)
            {
                PNIngredientRow ing = ingredients[x];
                string units    = ing.GetUnit().Abbreviation;
                double totalIng = processor.CalculateTotal(ing.DBName);

                WriteValue(xmlWriter, string.Format("i{0}qt",  x), totalIng.ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}qtk", x), (totalIng / prescription.DosingWeightInkg).ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}qt*", x), (totalIng / adultPeadWeightDiv).ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}qg",  x), totalIng.ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}qgk", x), (totalIng / prescription.DosingWeightInkg).ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}d",   x), UpperFirstChar(ing.Description));
                WriteValue(xmlWriter, string.Format("i{0}u",   x), units);
                WriteValue(xmlWriter, string.Format("i{0}uk",  x), units + "/kg");
                WriteValue(xmlWriter, string.Format("i{0}u*",  x), units + adultPeadUnitDivStr);
            }

            // Calories of Fat and glucose
            double totalCals = processor.CalculateTotal(PNIngDBNames.Calories);
            double totalN    = processor.CalculateTotal(PNIngDBNames.Nitrogen);
            WriteValue(xmlWriter, "kcalpergN", (totalCals > 0.01) ? Math.Round(totalCals / totalN).ToVDUIncludeZeroString() : string.Empty);

            WriteValue(xmlWriter, "kcal%Fat:CHO", processor.CalculateCalorieRatio());
            WriteValue(xmlWriter, "TotkcalFat",   processor.CalculatekcalFat().ToVDUIncludeZeroString());
            WriteValue(xmlWriter, "TotkcalCHO",   processor.CalculatekcalCHO().ToVDUIncludeZeroString());

            // Calcaulte totals splitting into combined or aqueous and lipid
            for (int i = 0; i < ingredients.Count; i++)
            {
                PNIngredientRow ing   = ingredients[i];
                double          total = aqueousOrCombinedItems.CalculateTotal(ing.DBName);

                WriteValue(xmlWriter, string.Format("i{0}qa",  i), total.ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}qak", i), (total / prescription.DosingWeightInkg).ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("i{0}qa*", i), (total / adultPeadWeightDiv).ToVDUIncludeZeroString());
            }

            if (!regimen.IsCombined)
            {
                for (int i = 0; i < ingredients.Count; i++)
                {
                    PNIngredientRow ing   = ingredients[i];
                    double          total = lipidOnlyItems.CalculateTotal(ing.DBName);

                    WriteValue(xmlWriter, string.Format("i{0}qb",  i), total.ToVDUIncludeZeroString());
                    WriteValue(xmlWriter, string.Format("i{0}qbk", i), (total / prescription.DosingWeightInkg).ToVDUIncludeZeroString());
                    WriteValue(xmlWriter, string.Format("i{0}qb*", i), (total / adultPeadWeightDiv).ToVDUIncludeZeroString());
                }
            }

            // Warning message
            temp = string.Empty;
            if (totalVolume > 0)
            {
                if ((processor.RegimenItems.CalculateTotal(PNIngDBNames.Potassium) / (totalVolume  / 1000.0)) > 60.0) { temp += "[KWarn]";  }
                if ((processor.RegimenItems.CalculateTotal(PNIngDBNames.Sodium   ) / (totalVolume  / 1000.0)) > 80.0) { temp += "[NaWarn]"; }
                if ((processor.RegimenItems.CalculateTotal(PNIngDBNames.Calcium  ) / (totalVolume  / 1000.0)) > 05.0) { temp += "[CaWarn]"; }
                if ((processor.RegimenItems.CalculateTotal(PNIngDBNames.Magnesium) / (totalVolume  / 1000.0)) > 03.8) { temp += "[MgWarn]"; }
                if (processor.RegimenItems.CalculateTotal(PNIngDBNames.Zinc) > 200.0) { temp += "[ZnWarn]"; }
            }
            WriteValue(xmlWriter, "warnings", temp);

            // Amino value
            if (totalAmino > 0)
            {
                WriteValue(xmlWriter, "kconc",      (processor.RegimenItems.CalculateTotal(PNIngDBNames.Potassium) / (totalAmino / 1000.0)).ToVDUIncludeZeroString());
                WriteValue(xmlWriter, "naconc",     (processor.RegimenItems.CalculateTotal(PNIngDBNames.Sodium   ) / (totalAmino / 1000.0)).ToVDUIncludeZeroString());
                //TFS30691 28Mar12 XN Corrected calculation of glucose concentration
                WriteValue(xmlWriter, "glucaconc",  (processor.CalculateGlucosePercenrtage(PNProductType.Aqueous) ?? 0.0).ToVDUIncludeZeroString());
                //WriteValue(xmlWriter, "glucaconc",  (processor.RegimenItems.FindByOnlyContainGlucose().CalculateTotal(PNIngDBNames.Volume) / totalAmino * 100.0).ToVDUIncludeZeroString());
            }
            else
            {
                WriteValue(xmlWriter, "kconc",      "N/A");
                WriteValue(xmlWriter, "naconc",     "N/A");
                WriteValue(xmlWriter, "glucaconc",  "N/A");
            }

            // Total volumes
            WriteValue(xmlWriter, "totvol",    totalVolume.ToString("0.#"));
            WriteValue(xmlWriter, "totml3sf",  totalVolume.ToVDUIncludeZeroString());
            WriteValue(xmlWriter, "totml/kg",  (totalVolume / prescription.DosingWeightInkg).ToVDUIncludeZeroString());
            WriteValue(xmlWriter, "totmla3sf", regimen.IsCombined ? totalVolume.ToVDUIncludeZeroString() : totalAmino.ToVDUIncludeZeroString());
            WriteValue(xmlWriter, "totmlb3sf", regimen.IsCombined ? 0.0.ToVDUIncludeZeroString()         : totalLipid.ToVDUIncludeZeroString());

	        double totalVolumeWithOverage = 0.0;
			double totalAminoWithOverage = 0.0;
			double totalLipidWithOverage = 0.0;

			double totalAminoWeight = (regimen.IsCombined ? totalVolume : totalAmino) * regimen.SupplyMultiplier;
			double totalLipidWeight = (regimen.IsCombined ? totalVolume : totalLipid) * regimen.SupplyMultiplier;
			double aminoWeightWithOverage = aqueousOnlyItems.Sum(i => (processor.CalculateProductOverage(i.GetProduct().PNCode, totalAminoWeight) + i.VolumneInml * regimen.SupplyMultiplier) * i.GetProduct().SpGrav);
			double lipidWeightWithOverage = lipidOnlyItems.Sum(i => (processor.CalculateProductOverage(i.GetProduct().PNCode, totalLipidWeight) + i.VolumneInml * regimen.SupplyMultiplier) * i.GetProduct().SpGrav);

            if (regimen.IsCombined)
            {
                totalVolumeWithOverage = (totalVolume * regimen.SupplyMultiplier) + regimen.OverageAqueousOrCombined ?? 0.0;
				totalAminoWithOverage = totalVolumeWithOverage;
				totalLipidWithOverage = 0.0;

				aminoWeightWithOverage = aminoWeightWithOverage + lipidWeightWithOverage;
				lipidWeightWithOverage = 0.00;
			}
            else
            {
				totalAminoWithOverage = (totalAmino * regimen.SupplyMultiplier) + regimen.OverageAqueousOrCombined ?? 0.0;
                totalLipidWithOverage = (totalLipid * regimen.SupplyMultiplier) + regimen.OverageLipid ?? 0.0;
	            totalVolumeWithOverage = totalAminoWithOverage + totalLipidWithOverage;
            }

			WriteValue(xmlWriter, "totmlovg", totalVolumeWithOverage.ToVDUIncludeZeroString());
			WriteValue(xmlWriter, "totmlovga", totalAminoWithOverage.ToVDUIncludeZeroString());
			WriteValue(xmlWriter, "totmlovgb", totalLipidWithOverage.ToVDUIncludeZeroString());

            WriteValue(xmlWriter, "totwtovga", aminoWeightWithOverage.ToVDUIncludeZeroString());
            WriteValue(xmlWriter, "totwtovgb", lipidWeightWithOverage.ToVDUIncludeZeroString());

            WriteValue(xmlWriter, "overagea", (regimen.OverageAqueousOrCombined ?? 0.0).ToVDUIncludeZeroString());
            WriteValue(xmlWriter, "overageb", (regimen.OverageLipid             ?? 0.0).ToVDUIncludeZeroString());

            WritePrintIng(xmlWriter, "printigs", processor.RegimenItems);
            WritePrintIng(xmlWriter, "printiga", aqueousOnlyItems      );
            WritePrintIng(xmlWriter, "printigb", lipidOnlyItems        );

            //WriteValue(xmlWriter, "day", supply.AdminStartDate.HasValue ? "[l.for]" + supply.AdminStartDate.Value.DayOfWeek : string.Empty);

            WriteValue(xmlWriter, "ivtype", regimen.CentralLineOnly ? "[IVcent]" : "[IVCorP]");

            // glucose mg/kg/min
            double totalGlucose = aqueousOrCombinedItems.CalculateTotal(PNIngDBNames.Glucose);
            if (regimen.InfusionHoursAqueousOrCombined > 0.0 && prescription.DosingWeightInkg > 0.0 && totalGlucose > 0.0)
                temp = (((totalGlucose * 1000) / prescription.DosingWeightInkg) / (regimen.InfusionHoursAqueousOrCombined * 60.0)).ToVDUIncludeZeroString();
            else
                temp = "----";
            WriteValue(xmlWriter, "Gluc:mg/kg/min", temp);

            // Add product volumes
            for (int x = 0; x < aqueousOrCombinedItems.Count; x++)
            {
                PNRegimenItem item = aqueousOrCombinedItems[x];
                WriteValue(xmlWriter, string.Format("p{0}qa",  x+1), item.VolumneInml.ToVDUIncludeZeroString());
                WriteValue(xmlWriter, string.Format("p{0}qao", x + 1), processor.CalculateProductOverage(item.PNCode, totalAmino).ToVDUIncludeZeroString());  // TFS29387 21Mar12 XN incorrect calculation of overage was using product volume rather than total volume
                WriteValue(xmlWriter, string.Format("p{0}da",  x+1), item.GetProduct().Description);
                WriteValue(xmlWriter, string.Format("p{0}ua",  x+1), "[ml]");
            }
            for (int x = aqueousOrCombinedItems.Count; x < 20; x++)
            {
                WriteValue(xmlWriter, string.Format("p{0}qa",  x+1), string.Empty); 
                WriteValue(xmlWriter, string.Format("p{0}qao", x+1), string.Empty); 
                WriteValue(xmlWriter, string.Format("p{0}da",  x+1), string.Empty);
                WriteValue(xmlWriter, string.Format("p{0}ua",  x+1), string.Empty);
            }

            if (!regimen.IsCombined)
            {
                for (int x = 0; x < lipidOnlyItems.Count; x++)
                {
                    PNRegimenItem item = lipidOnlyItems[x];
                    WriteValue(xmlWriter, string.Format("p{0}qb",  x+1), item.VolumneInml.ToVDUIncludeZeroString());
                    WriteValue(xmlWriter, string.Format("p{0}qbo", x + 1), processor.CalculateProductOverage(item.PNCode, totalLipid).ToVDUIncludeZeroString()); 
                    WriteValue(xmlWriter, string.Format("p{0}db",  x+1), item.GetProduct().Description);
                    WriteValue(xmlWriter, string.Format("p{0}ub",  x+1), "[ml]");
                }
            }
            for (int x = regimen.IsCombined ? 0 : lipidOnlyItems.Count; x < 20; x++)
            {
                WriteValue(xmlWriter, string.Format("p{0}qb",  x+1), string.Empty); 
                WriteValue(xmlWriter, string.Format("p{0}qbo", x+1), string.Empty); 
                WriteValue(xmlWriter, string.Format("p{0}db",  x+1), string.Empty);
                WriteValue(xmlWriter, string.Format("p{0}ub",  x+1), string.Empty);
            }

            // Add infusion rate
            double activeVolume = (regimen.IsCombined ? totalVolume : totalAmino);
            string oneSigFig, twoSigFig;
            string infusionRate;
            if (regimen.InfusionHoursAqueousOrCombined > 0.0)
            {
                infusionRate = (activeVolume/regimen.InfusionHoursAqueousOrCombined).To2SigFigString();
                if (infusionRate.IndexOf(".0", System.StringComparison.Ordinal) != -1)
                    infusionRate = infusionRate.Substring(0, infusionRate.Length - 2);

                oneSigFig = "[l.Infuse]" + activeVolume.ToVDUIncludeZeroString() + " [ml][l.over] " + regimen.InfusionHoursAqueousOrCombined + "[l.at]" + infusionRate + "[l.mlperhr]";
                //twoSigFig = "[l.Infuse]" + activeVolume.ToVDUIncludeZeroString() + " [ml][l.over] " + regimen.InfusionHoursAqueousOrCombined + "[l.at]" + (activeVolume / regimen.InfusionHoursAqueousOrCombined).ToVDUIncludeZeroString()      + "[l.mlperhr]"; 02Jun16 XN 154627
                twoSigFig = "[l.Infuse]" + activeVolume.ToVDUIncludeZeroString() + " [ml][l.over] " + regimen.InfusionHoursAqueousOrCombined + "[l.at]" + (activeVolume / regimen.InfusionHoursAqueousOrCombined).To3SigFigString() + "[l.mlperhr]";
            }
            else if (regimen.IsCombined && (totalVolume > 0.0))
                oneSigFig = twoSigFig = " [l.volume] " + totalVolume.ToVDUIncludeZeroString() + "[ml] ";
            else if (!regimen.IsCombined && (totalAmino > 0.0))
                oneSigFig = twoSigFig = " [l.volume] " + totalAmino.ToVDUIncludeZeroString() + "[ml] ";
            else
                oneSigFig = twoSigFig = "Not applicable";
            WriteValue(xmlWriter, "infratea",      oneSigFig);
            WriteValue(xmlWriter, "infratea_full", twoSigFig);

            if (regimen.InfusionHoursLipid > 0.0)
            {
                infusionRate = (totalLipid/regimen.InfusionHoursLipid).To2SigFigString();
                if (infusionRate.IndexOf(".0", System.StringComparison.Ordinal) != -1)
                    infusionRate = infusionRate.Substring(0, infusionRate.Length - 2);
                oneSigFig = "[l.Infuse][totmlB3sf] [ml][l.over] " + regimen.InfusionHoursLipid + "[l.at]" + infusionRate + "[l.mlperhr]";
                //twoSigFig = "[l.Infuse][totmlB3sf] [ml][l.over] " + regimen.InfusionHoursLipid + "[l.at]" + (totalLipid / regimen.InfusionHoursLipid).ToVDUIncludeZeroString()      + "[l.mlperhr]";  02Jun16 XN 154627
                twoSigFig = "[l.Infuse][totmlB3sf] [ml][l.over] " + regimen.InfusionHoursLipid + "[l.at]" + (totalLipid / regimen.InfusionHoursLipid).To3SigFigString() + "[l.mlperhr]";
            }
            else if (totalLipid > 0.0)
                oneSigFig = twoSigFig = " [l.volume] [totmlB3sf] [ml]";
            else
                oneSigFig = twoSigFig = "Not applicable";
            WriteValue(xmlWriter, "infrateb",      oneSigFig);
            WriteValue(xmlWriter, "infrateb_full", twoSigFig);

            WriteValue(xmlWriter, "parta", regimen.IsCombined ? string.Empty : "[l.parta]");

            // Add fixed text printing items
            IDictionary<string,string> fixedText = WConfigurationController.LoadByCategoryAndSection(SessionInfo.SiteID, "D|PN.", "PrintFixedText", true);
            foreach (KeyValuePair<string, string> txt in fixedText)
            {
                if (!StringExtensions.IsNullOrEmptyAfterTrim(txt.Key))
                    WriteValue(xmlWriter, txt.Key, txt.Value);
            }
            WriteValue(xmlWriter, "AqueousHeader", regimen.IsCombined ? "[Hdr3]" : "[Hdr1]");
            WriteValue(xmlWriter, "LipidHeader",   regimen.IsCombined ? "[Hdr0]" : "[Hdr2]");

            // Osmolality
            List<string> PNCodesMissed, PNCodesInvalidVol;
            double osmolality = processor.CalculateOsmolality(out PNCodesMissed, out PNCodesInvalidVol);
            int misssingCount = PNCodesMissed.Count + PNCodesInvalidVol.Count;
            temp =  osmolality.ToVDUIncludeZeroString() + " mOsmol per kg water";
            if (misssingCount > 0)
                temp += " (Caution: Data not known for " + misssingCount + " products)";
            WriteValue(xmlWriter, "Osmolality", temp); 

            // Solubility index
            double solubilityIndex = processor.CheckCaPO4Solubility();
            WriteValue(xmlWriter, "CaPO4SolIndex",  solubilityIndex.ToString("0.00"));
            WriteValue(xmlWriter, "CaPO4SolIndex%", (solubilityIndex * 100).ToString("#"));

            // New tags
            WriteValue(xmlWriter, "supply",       regimen.Supply48Hours ? "48Hrs" : "24Hrs");

            // Add syringe items TFS30748 29Mar12 XN
            WriteValue(xmlWriter, "NumberOfSyringes",   regimen.NumberOfSyringes);
            WriteValue(xmlWriter, "SyringeDescription", WConfigurationController.LoadAndCache<string>(SessionInfo.SiteID, "D|PN", "LipidSyringes", "SyringeDescription", string.Empty, false));
            WriteValue(xmlWriter, "RTFForSyringe",      WConfigurationController.LoadAndCache<string>(SessionInfo.SiteID, "D|PN", "LipidSyringes", "RTFforSyringe",      string.Empty, false));
        }

        /// <summary>Create PN print XML for supply request    11Sep14 XN  88799</summary>
        private static void WriteSupplyRequest(XmlWriter xmlWriter, PNSupplyRequestRow supply, PNRegimenRow regimen)
        {
            WriteValue(xmlWriter, "PNreqdate",  supply.AdminStartDate.ToPharmacyDateString());
            WriteValue(xmlWriter, "PNduration", supply.DaysRequested.ToString());
            WriteValue(xmlWriter, "numofbags",  supply.DaysRequested.HasValue ? (supply.DaysRequested.Value / regimen.SupplyMultiplier).ToString("#.#") : string.Empty);
            WriteValue(xmlWriter, "batchno",    supply.BatchNumber.FixedWidthPadRight(9));
            WriteValue(xmlWriter, "day",        supply.AdminStartDate.HasValue ? "[l.for]" + supply.AdminStartDate.Value.DayOfWeek : string.Empty);
        
            // TFS30667 XN 28Mar12 Set expiry to date rather than days
            WriteValue(xmlWriter, "expirya", supply.ExpiryAqueousCombined.ToString("dd MMM yyyy"));
            string expiryb = string.Empty;
            if (supply.ExpiryLipid.HasValue)
                expiryb = supply.ExpiryLipid.Value.ToString("dd MMM yyyy");
            WriteValue(xmlWriter, "expiryb", expiryb);
        }

        /// <summary>
        /// Used to load in site specific print data using sp pSiteSpecificRxPrinting (note this SP is shared by vb client for normal dispensing)
        /// SP should only return a single row that is added to the print heap where column name is the print tag
        /// 28Sep15 XN 77778
        /// </summary>
        /// <param name="xmlWriter">XML heap writer</param>
        /// <param name="prescrtiption">PN Prescription</param>
        /// <param name="regimen">Regimen row</param>
        private static void WriteSiteSpecificPrinting(XmlWriter xmlWriter, PNPrescriptionRow prescrtiption, PNRegimenRow regimen)
        {
            // If SP does not exist in the DB then end as site does not have any site specific printing
            if (!Database.CheckSPExist("pSiteSpecificRxPrinting"))
            {
                return;
            }

            // Call the SP
            GenericTable2 table = new GenericTable2();
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID", SessionInfo.SiteID);
            parameters.Add("RequestID_Prescription", prescrtiption.RequestID);
			parameters.Add("RequestID_Child", regimen == null ? (int?)null : regimen.RequestID);
            table.LoadBySP("pSiteSpecificRxPrinting", parameters);

            // Hong Kong specific configuration 01Oct15 XN 130210
            // Converts Chinese name to RTF image (if empty use English name 03Oct15 XN 133949)
            if (table.Table.Rows.Count > 0 && table.Table.Columns.IndexOf("ChineseName") >= 0)
            {
                foreach (DataRow r in table.Table.Rows)
                {
                    string chinese = r["ChineseName"] as string;
                    r["ChineseName"] = string.IsNullOrWhiteSpace(chinese) ? PNPrintProcessor.BuildName(Patient.GetByEpisodeId(prescrtiption.EpisodeID)) : RTFUtils.TextToRTFImage(chinese);
                }
            }

            // Places the data on the heap (only ever 1 row column name is print tag)
            BaseRow row = table.FirstOrDefault();
            foreach (DataColumn col in table.Table.Columns)
            {
                var val = row == null ? null : row.RawRow[col.ColumnName];

                xmlWriter.WriteStartElement(col.ColumnName);
                xmlWriter.WriteAttributeString("alias", "1");   // Though not an alias force the client side to add it to print heap else gets ignored
                xmlWriter.WriteValue(val == null ? string.Empty : val.ToString());
                xmlWriter.WriteEndElement();                       
            }                
        }

        /// <summary>
        /// Adds all the items in the list as print items to xml (as single node)
        ///     [PrintIg1]Vamin 9 10.2[PrintIg2][PrintIg1]Glucose 50% 1020[PrintIg2]
        /// </summary>
        /// <param name="xmlWriter">Xml being written to</param>
        /// <param name="elementName">Name of the xml item to write</param>
        /// <param name="items">List of items to write</param>
        private static void WritePrintIng(XmlWriter xmlWriter, string elementName, IEnumerable<PNRegimenItem> items)
        {
            StringBuilder str = new StringBuilder();
            foreach (PNRegimenItem i in items)
            {
                str.Append("[PrintIg1]");
                str.Append(i.GetProduct().Description.FixedWidthPadRight(30));
                str.Append(" ");
                str.Append(i.VolumneInml.ToVDUIncludeZeroString());
                str.Append("[PrintIg2]");
            }

            WriteValue(xmlWriter, elementName, str.ToString());
        }

        /// <summary>
        /// Writes value as a node value pair
        /// If element name contains invalid xml chars (one of /*%:) these are converted to '_'
        /// </summary>
        /// <typeparam name="T">Value type</typeparam>
        /// <param name="xmlWriter">Xml to write to</param>
        /// <param name="elementName">Element name</param>
        /// <param name="value">Value to write</param>
        private static void WriteValue<T>(XmlWriter xmlWriter, string elementName, T value)
        {
            elementName = elementName.Replace('/', '_').Replace('*', '_').Replace('%', '_').Replace(':', '_');
            xmlWriter.WriteStartElement(elementName);
            xmlWriter.WriteValue(value);
            xmlWriter.WriteEndElement();
        }

        /// <summary>
        /// Writes products for worksheet table as 
        ///     {typeIDPrefix{SG}}
        ///         {PNProductID}12457{PNProductID}
        ///         {Description}Vamin 9{/Description}
        ///         {mls}34.5{/mls}                     -- product overage in ml
        ///         {grams}34.5{/grams}                 -- product weight in grams
        ///     {/typeIDPrefix{SG}}
        ///     
        /// </summary>
        /// <param name="xmlWriter">Xml to write to</param>
        /// <param name="items">items to write</param>
        /// <param name="typeIDPrefix">element node prefix (adds SG to name if product has sp grav)</param>
        /// <param name="processor">PN Processor</param>
        /// <param name="totalVolume">total volume for items</param>
        private static void WriteWorksheetTable(XmlWriter xmlWriter, IEnumerable<PNRegimenItem> items, string typeIDPrefix, PNProcessor processor, double totalVolume, double supplyMultiplier)
        {
            foreach (var i in items)
            {
                PNProductRow product = i.GetProduct();
                double overageInml = processor.CalculateProductOverage(product.PNCode, totalVolume * supplyMultiplier) + i.VolumneInml * supplyMultiplier;

                xmlWriter.WriteStartElement( typeIDPrefix + (product.SpGrav > 0.0 ? "SG" : string.Empty) );
                WriteValue(xmlWriter, "PNProductID", product.PNProductID);
                WriteValue(xmlWriter, "Description", product.Description);
                WriteValue(xmlWriter, "mls",         overageInml.ToVDUIncludeZeroString());                            
                WriteValue(xmlWriter, "grams",       (overageInml * product.SpGrav).ToVDUIncludeZeroString()); 
                xmlWriter.WriteEndElement();
            }
        }

        /// <summary>
        /// Write constitutions xml element as single node
        ///     {elementName}[condOn][Calories]15.6[Cals][Nitrogen]10.0[gram]...{/elementName}
        /// </summary>
        /// <param name="xmlWriter">Xml to write to</param>
        /// <param name="elementName">Element name</param>
        /// <param name="items">Number of items in regimen</param>
        /// <param name="isCombined">If regimen is combined</param>
        /// <param name="perKilo">If display values as per kilo or total</param>
        /// <param name="dosingWeight">Dosing weight of patient</param>
        private static void WriteConstituents(XmlWriter xmlWriter, string elementName, IEnumerable<PNRegimenItem> items, bool isCombined, bool perKilo, double dosingWeight)
        {
            StringBuilder temp = new StringBuilder();

            double weightDiv = perKilo ? dosingWeight : 1.0;
            string kgStr     = perKilo ? "kg"         : string.Empty;

            double calories = items.CalculateTotal(PNIngDBNames.Calories) / weightDiv;
            double nitrogen = items.CalculateTotal(PNIngDBNames.Nitrogen) / weightDiv;

            temp.Append("[condOn]");
            temp.Append("[Calories]"    + (items.CalculateTotal(PNIngDBNames.Calories    ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[Cals]");
            temp.Append("[Nitrogen]"    + nitrogen.ToVDUIncludeZeroString().PadLeft(4) + "[gram]");
            temp.Append("[Glucose]"     + (items.CalculateTotal(PNIngDBNames.Glucose     ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[gram][cr]");
            if (isCombined)
                temp.Append("[Fat]" + (items.CalculateTotal(PNIngDBNames.Fat) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[gram]");
            else
                temp.Append("[FatinPB]");
            temp.Append("[sodium]"      + (items.CalculateTotal(PNIngDBNames.Sodium      ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol]");
            temp.Append("[Potassium]"   + (items.CalculateTotal(PNIngDBNames.Potassium   ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol][cr]");
            temp.Append("[Calcium]"     + (items.CalculateTotal(PNIngDBNames.Calcium     ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol]");
            temp.Append("[Magnesium]"   + (items.CalculateTotal(PNIngDBNames.Magnesium   ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol]");
            temp.Append("[Zinc]"        + (items.CalculateTotal(PNIngDBNames.Zinc        ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[umol][cr]");
            temp.Append("[Phosphate]"   + (items.CalculateTotal(PNIngDBNames.Phosphate   ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol]");
            temp.Append("[Chloride]"    + (items.CalculateTotal(PNIngDBNames.Chloride    ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol]");
            temp.Append("[Acetate]"     + (items.CalculateTotal(PNIngDBNames.Acetate     ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[mmol][cr]");
            temp.Append("[Selenium]"    + (items.CalculateTotal(PNIngDBNames.Selenium    ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[nmol]");
            temp.Append("[Copper]"      + (items.CalculateTotal(PNIngDBNames.Copper      ) / weightDiv).ToVDUIncludeZeroString().PadLeft(4) + "[umol]");
            if (nitrogen > 0.0)
                temp.Append("[kcalpergN]"   + Math.Floor(calories / (nitrogen * weightDiv)).ToVDUIncludeZeroString().PadLeft(4) + "[CalN]");

            WriteValue(xmlWriter, elementName, temp.ToString());
        }

        /// <summary>
        /// Build up patients name 
        /// depends on settings
        /// Category: D|PN
        /// Section: PrintSetting
        /// Key: SurnameForename
        /// 
        /// Category: D|PN
        /// Section: PrintSetting
        /// Key: CommaSeparatedName
        /// 
        /// if SurnameForename
        ///     {surename}, {forname}
        /// else
        ///     {forname} {surename}
        ///     
        /// Comma depends on setting CommaSeparatedName
        /// 133949 XN 2Nov15 Made public so does can be used by Hong Kong custom web service
        /// </summary>
        /// <param name="patient">Patient details</param>
        /// <returns>Patient name</returns>
        public static string BuildName(PatientRow patient)
        {
            StringBuilder name = new StringBuilder();
            bool surenameForename   = PNSettings.PrintSetting.GetSurnameForname();
            bool commaSeparatedName = PNSettings.PrintSetting.GetCommaSeparatedName();

            if (!surenameForename)
                return patient.Forename.Trim() + " " + patient.Surname.Trim();
            else if (!StringExtensions.IsNullOrEmptyAfterTrim(patient.Forename))
                return patient.Surname.Trim() + (commaSeparatedName ? ", " : " ") + patient.Forename.Trim();
            else
                return patient.Surname;
        }

        /// <summary>Returns string with first char as upper case</summary>
        private static string UpperFirstChar(string str)
        {
            return string.IsNullOrEmpty(str) ? str : Char.ToUpper(str[0]) + str.Remove(0, 1);
        }

        /// <summary>
        /// Returns print alias setting this will be a WConfiguration setting
        /// Category: D|PN
        /// Section: PrintSetting
        /// Key: EntityAlias or RequestAlias
        /// The setting is a CSV list of settings in form
        ///     {alias name}:{print tag}
        /// 24Sep15 XN 77778
        /// </summary>
        /// <param name="category">Setting category</param>
        /// <param name="section">Setting section</param>
        /// <param name="key">Setting key</param>
        /// <returns>Dictionary of key=alias name and value=print tag</returns>
        private static IDictionary<string,string> GetPrintAliasesSetting(string category, string section, string key)
        {
            Dictionary<string,string> result = new Dictionary<string, string>();
            foreach (var s in WConfiguration.Load(SessionInfo.SiteID, category, section, key, string.Empty, false).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                string[] split = s.Split(':');            
                string aliasGroup = split.Length == 0 ? string.Empty : split[0];
                string printTag   = split.Length <= 1 ? string.Empty : split[1];
                result[aliasGroup] = printTag;
            }
            return result;
        }
    }
}
