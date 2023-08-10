//===========================================================================
//
//						    PharmacyInterface.cs
//
//  Creates the old style (vb6) pharmacy interface files from an RTF, using 
//  the print heap for each pharmacy object.
//  
//  To allow the system to work on hosted solution the complete RTF file
//  will be saved to a hidden field on the page (using RegisterHiddenField)
//  The client side method saveInterfaceFile (in pharmacyscript.js) is then called this
//      reads the file content from the hidden
//      saves it to a temp file
//      then renames the temp file to correct filename
//      deletes the hidden field
//  This mean the class only works when used in a web site
//
//  Also to allow the system to work in a hosted environment means the rtf file can't 
//  be read from the disp data folder to get around this suggest storing the RTF file content in 
//  the config setting D|GenInt.{interface setting}.RTFFile (rather than the name)
//
//  The class will parse the OutputRefNoPad, and TransactionRef tag against the RTF file (used for file counter)
//
//  If IPharmacyInterfaceSettings.Enabled is false the class will not do anything
//
//  The class will NOT support message batching
//
//  Usage
//  WSupplier supplier = new WSupplier();
//  supplier.LoadBySupCodAndSite(supcode, siteID);
//
//  SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
//
//  PharmacyInterface interfaceFile = new PharmacyInterface();
//  interfaceFile.Initalise( supplier.ToXMLHeap(), settings );
//  PharmacyInterface.Save();
//  
//	Modification History:
//	11Nov14 XN  Written 43318
//  15Apr16 XN  Added ParseXml, updated Save to support msg batching 123082
//  24May16 XN  124812 Initialise update due to change in SiteInfo.DispdataDRV
//  15Aug16 XN  Updated Initialise, and Save, added ParseXml 108889
//  17Aug16 XN  Fixed issue with allowing to work with hosted file 160358
//===========================================================================
using System;
using System.IO;
using System.Web;
using System.Web.UI;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Creates a pharmacy interface files from an RTF using the print heap</summary>
    public class PharmacyInterface
    {
        /// <summary>Settings for the interface</summary>
        private IPharmacyInterfaceSettings settings;

        /// <summary>RTF file for the interface (from settings.RTFFile)</summary>
        private RTFParser parser = new RTFParser();

        /// <summary>Initialise the class</summary>
        /// <param name="settings">Settings</param>
        public void Initialise(IPharmacyInterfaceSettings settings)
        {
            this.settings = settings;
            if (settings.Enabled)
            {
                // Get the RTF file name and checks it exists
                string RTFFile = settings.RTFFile;
                if (string.IsNullOrEmpty(RTFFile))
                    throw new ApplicationException("Generic Interface Incorrectly configured - Supplier RTF File not specified (D|GenInt.SupplierInterface.RTFFile)");
                //RTFFile = Path.Combine(SiteInfo.DispdataDRVBySite(settings.SiteID), string.Format("dispdata.{0:000}",  Sites.GetNumberBySiteID(settings.SiteID) ), RTFFile); 24May16 XN 124812 update due to change in SiteInfo.DispdataDRV
                
                // Check if the RTFFile is the name or the RTF file content
                parser = new RTFParser();
                if (RTFFile.Length > 4 && RTFFile[RTFFile.Length - 4] == '.')
                {
                    // RTF is the name so read the file                    
                    RTFFile = Path.Combine(SiteInfo.DispdataDRV(settings.SiteID), RTFFile);
                    if (!File.Exists(RTFFile))
                        throw new ApplicationException("Generic Interface Incorrectly configured - Supplier Export File Not Found (or web service does not have permission to access file)\nFile:" + RTFFile);

                    // Read and parse RTF
                    parser.Read(File.ReadAllText(RTFFile));
                }
                else
                    parser.Read(RTFFile);   // Read and parse RTF from setting 17Aug16 XN 160358
            }
        }

        /// <summary>Allows parsing Xml heap in form {Heap name='value' name='value' /} against the RTF file</summary>
        public void ParseXml(string xml)
        {
            parser.ParseXML(xml);
        }

        /// <summary>Allows parsing extra tags against the RTF file</summary>
        public void Parse(string tagName, string value)
        {
            parser.Parse(tagName, value);
        }

        /// <summary>
        /// Save the file to disk 
        /// 17Aug16 XN  Fixed issue with allowing to work with hosted file 160358
        /// </summary>
        public void Save()
        {
            if (settings.Enabled)
            {
                // Get the output filename
                string outputDir = settings.ExportPath;
                if (string.IsNullOrEmpty(outputDir))
                    throw new ApplicationException("Generic Interface Incorrectly configured - Export path not specified");
                if (settings.UseFileBatching)
                    throw new ApplicationException("Generic interface file batching not supported.");

                // Get the counter
                int pointer = WFilePointer.Increment(settings.SiteID, settings.FilePointerName);

                // Parse counter
                parser.Parse("TransactionRef", string.Format("{0}{1}{2:00000000}", DateTime.Now.Year, DateTime.Now.Month, pointer));
                parser.Parse("OutputRefNoPad", pointer.ToString());

                // Get filename
                string tempFilename   = string.Format("{0}{1:0000000000}{2}.tmp", settings.FilePrefix, pointer, settings.FileSuffix);
                tempFilename = Path.Combine(outputDir, tempFilename);

                string outputFilename = string.Format("{0}{1:0000000000}{2}{3}", settings.FilePrefix, pointer, settings.FileSuffix, settings.FileExtension);
                outputFilename = Path.Combine(outputDir, outputFilename);

                string hiddenFieldName = string.Format("hfInterfaceFile{0}{1:0000000000}{2}", settings.FilePrefix, pointer, settings.FileSuffix);

                // To support hosted solutions the interface needs to save content to hidden field and use saveInterfaceFile to save the file
                if (HttpContext.Current != null && (HttpContext.Current.Handler is Page))
                {
                    Page page = (HttpContext.Current.Handler as Page);
                    ScriptManager.RegisterHiddenField(page, hiddenFieldName, parser.ToString());
                    string script = string.Format("saveInterfaceFile(JavaStringUnescape('{0}'), JavaStringUnescape('{1}'), JavaStringUnescape('{2}'));", tempFilename.JavaStringEscape(), outputFilename.JavaStringEscape(), hiddenFieldName.JavaStringEscape());
                    ScriptManager.RegisterStartupScript(page, page.GetType(), "script" + hiddenFieldName, script, true);
                }
            }
        }
        //public void Save()
        //{
        //    if ( settings.Enabled )
        //    {
        //        // Get the output filename
        //        string outputDir = settings.ExportPath;
        //        if (string.IsNullOrEmpty(outputDir))
        //            throw new ApplicationException("Generic Interface Incorrectly configured - Export path not specified");
        //        if (!Directory.Exists(outputDir))
        //            throw new ApplicationException("Generic Interface Incorrectly configured - Export Path Not Found (or web service does not have permission to access file) \nPath:" + outputDir);
        //        if (settings.UseFileBatching && settings.BatchTotal == 0)
        //            throw new ApplicationException("Generic Interface Incorrectly configured - File Batching enabled without BatchTotal being set.");

        //        // Get the counter
        //        int pointer = WFilePointer.Increment(settings.SiteID, settings.FilePointerName);

        //        // Parse counter
        //        parser.Parse("TransactionRef", string.Format("{0}{1}{2:00000000}", DateTime.Now.Year, DateTime.Now.Month, pointer));
        //        parser.Parse("OutputRefNoPad", pointer.ToString());

        //        string outputFilename, tempFilename;
        //        if (settings.UseFileBatching)
        //        {
        //            // Msg batching mode

        //            // Find if an existing temporary file exists
        //            var files = Directory.GetFiles(outputDir, string.Format("{0}*{1}.tmp", settings.FilePrefix, settings.FileSuffix));
        //            if (files.Length > 0)
        //            {
        //                outputFilename = files[0];
        //            }
        //            else
        //            {
        //                outputFilename = Path.Combine(outputDir, string.Format("{0}{1:0000000000}{2}.tmp", settings.FilePrefix, pointer, settings.FileSuffix));
        //            }
                    
        //            // Update the temporary file
        //            File.AppendAllText(outputFilename, parser.ToString());

        //            // If reached the batch total, then save to output file
        //            if (((pointer % settings.BatchTotal) == 0 || pointer == 1))
        //            {
        //                File.Move(outputFilename, outputFilename.Replace(".tmp", settings.FileExtension));

        //                // Clear down file ready for the next
        //                foreach (var f in Directory.GetFiles(outputDir, string.Format("{0}*{1}.tmp", settings.FilePrefix, settings.FileSuffix)))
        //                {
        //                    File.Delete(f);
        //                }
        //            }
        //        }
        //        else
        //        {
        //            // One msg per file mode
        //            tempFilename   = string.Format("{0}{1:0000000000}{2}.tmp", settings.FilePrefix, pointer, settings.FileSuffix);
        //            tempFilename = Path.Combine(outputDir, tempFilename);

        //            outputFilename = string.Format("{0}{1:0000000000}{2}{3}", settings.FilePrefix, pointer, settings.FileSuffix, settings.FileExtension);
        //            outputFilename = Path.Combine(outputDir, outputFilename);

        //            // Save the file (if it does not exist)
        //            if (!File.Exists(outputFilename))
        //            {
        //                File.WriteAllText(tempFilename, parser.ToString());
        //                File.Move(tempFilename, outputFilename);
        //            }
        //        }
        //    }
        //}
    }
}
