//===========================================================================
//
//						PharmacyInterfaceSettings.cs
//
//  Generic interface settings read from WConfiguration
//  Filtered to where Category='D|GenInt' and Section='GenericInterface' or 'SupplierInterface'
//
//  Currently the class only supports SupplierInterfaceSettings (due to legacy reasons this is used by WSupplier2 (E and S types) and WCustomer (W type)
//  These class implement the IPharmacyInterfaceSettings interface
//
//  Unlike other settings you must create a instalnce of the setting calls
//  to get access to the setting (so can use the standard IPharmacyInterfaceSettings interface)
//
//  Usage
//  To get if the interface is enabled (for external suppliers) do    
//  SupplierInterfaceSettings settings = new SupplierInterfaceSettings(siteID, SupplierType.External);
//  settings.Enabled
//
//  To get if the interface is enabled (for customer) do    
//  SupplierInterfaceSettings settings = new SupplierInterfaceSettings(siteID, SupplierType.Ward);
//  settings.Enabled
//  
//	Modification History:
//	11Nov14 XN  Written 43318
//  15Apr16 XN  123082 Added UseFileBatching, and BatchTotal to IPharmacyInterfaceSettings 
//              Also added class TranslogInterfaceSettings
//  15Aug16 XN  Fixed FilePointerName, added class StockInterfaceSettings 108889
//  16Aug16 XN  Fixed issue with FilePointerName
//===========================================================================
using System;
using System.IO;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Pharmacy interface files settings</summary>
    public interface IPharmacyInterfaceSettings
    {
        /// <summary>Site ID the setting is for</summary>
        int SiteID { get; }

        /// <summary>If the interface is enabled</summary>
        bool Enabled { get; }

        /// <summary>Gets RTF interface filename</summary>
        string RTFFile { get; }

        /// <summary>Export path for the interface file</summary>
        string ExportPath { get; }

        /// <summary>File pointer (or counter name)</summary>
        string FilePointerName { get; }

        /// <summary>Filename prefix</summary>
        string FilePrefix { get; }

        /// <summary>Filename suffix</summary>
        string FileSuffix { get; }

        /// <summary>Filename extension (default .xml)</summary>
        string FileExtension { get; }
    
        /// <summary>If using file batching</summary>
        bool UseFileBatching { get; }

        /// <summary>If using file batching</summary>
        int BatchTotal { get; }
    }

    /// <summary>Settings for the pharmacy generic interface (all of the setting come from WConfiguration mainly where Section='SupplierInterface')</summary>
    internal class SupplierInterfaceSettings : IPharmacyInterfaceSettings
    {
        private SupplierType supplierType;

        public SupplierInterfaceSettings (int siteID, SupplierType supplierType)
	    {
            this.SiteID       = siteID;
            this.supplierType = supplierType;
	    }

        /// <summary>Site ID the settings are for</summary>
        public int SiteID { get; private set; }

        /// <summary>
        /// If the supplier interface is enabled D|patmed.GenericInterface.SupplierInterface
        /// and supported by the interface D|GenInt.GenericInterface.SupplierTypes
        /// </summary>
        public bool Enabled 
        { 
            get 
            { 
                string supportedTypes = WConfiguration.LoadAndCache<string>(this.SiteID, "D|GenInt", "GenericInterface", "SupplierTypes", "EWS", false);
                return supportedTypes.Contains(EnumDBCodeAttribute.EnumToDBCode(supplierType)) && WConfiguration.LoadAndCache<bool>  (this.SiteID, "D|patmed", "GenericInterface", "SupplierInterface", false, false); 
            } 
        }

        /// <summary>
        /// Gets RTF interface filename for the supplier type (or default if no supplier type specific file)
        /// D|GenInt.GenericInterface.RTFFile{SupplierType} 
        /// else 
        /// D|GenInt.GenericInterface.RTFFile
        /// </summary>
        public string RTFFile
        { 
            get
            {
                string code = EnumDBCodeAttribute.EnumToDBCode(supplierType);
                string RTFFile = WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "RTFFile", string.Empty, false);
                return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "RTFFile" + code, RTFFile, false);
            }
        }

        /// <summary>Export path for the interface file D|GenInt.SupplierInterface.ExportFilePath</summary>
        public string ExportPath { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "ExportFilePath", string.Empty, false); } }

        /// <summary>File pointer (or counter name) GenInt.SupplierInterface.InterfacePointerFile</summary>
        public string FilePointerName 
        { 
            get 
            { 
                string dispData = WConfiguration.LoadAndCache<string>(this.SiteID, "D|Siteinfo", string.Empty, "DispdataDRV", string.Empty, false);
                //return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "InterfacePointerFile", Path.Combine(dispData, "SupInt"), false); 24Jun16 XN fixed  108889
                if (!dispData.EndsWith("\\"))
                    dispData += "\\";
                dispData = Path.Combine(dispData, string.Format("dispdata.{0:000}", Site2.GetSiteNumberByID(this.SiteID))) + "\\";
                string value = WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "InterfacePointerFile", Path.Combine(dispData, "SupInt"), false); 
                return value.Replace(dispData, "D|");
            } 
        }

        /// <summary>Filename prefix GenInt.SupplierInterface.FilePrefix</summary>
        public string FilePrefix { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "FilePrefix", "S", false); } }

        /// <summary>Filename suffix GenInt.SupplierInterface.Filesuffix</summary>
        public string FileSuffix { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "Filesuffix", string.Empty, false); } }

        /// <summary>Filename extension (default .xml) GenInt.SupplierInterface.OutputFileExtension</summary>
        public string FileExtension { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "SupplierInterface", "OutputFileExtension", ".xml", false); } }
    
        /// <summary>If using file batching returns false</summary>
        public bool UseFileBatching { get { return false; } }

        /// <summary>If using file batching returns 0</summary>
        public int BatchTotal { get { return 0; } }
    }

    /// <summary>Settings for the pharmacy translog interface file (all of the setting come from WConfiguration mainly where Section='TranslogInterface')</summary>
    public class TranslogInterfaceSettings : IPharmacyInterfaceSettings
    {
        /// <summary>Translog row kind</summary>
        private WTranslogType transKind;

        /// <summary>Translog label type</summary>
        private WTranslogType transLabel;

        /// <summary>Payment category</summary>
        private string paymentCategory;

        /// <summary>Is return</summary>
        private bool isReturn;

        /// <summary>Initialise the class</summary>
        /// <param name="siteID">Site id</param>
        /// <param name="paymentCategory">payment category</param>
        /// <param name="row">Translog row</param>
        public TranslogInterfaceSettings (int siteID, string paymentCategory, WTranslogRow row)
	    {
            this.SiteID          = siteID;
            this.transKind       = row.Kind;
            this.transLabel      = row.LabelType;
            this.paymentCategory = paymentCategory;
            this.isReturn        = row.QuantityInIssueUnits < 0;
	    }

        /// <summary>Site ID the settings are for</summary>
        public int SiteID { get; private set; }

        /// <summary>
        /// If the supplier interface is enabled 
        ///     D|patmed.GenericInterface.PrintingInterface
        ///     D|patmed.GenericInterface.TransKinds
        ///     D|patmed.GenericInterface.TransLabels
        /// </summary>
        public bool Enabled 
        { 
            get 
            { 
                string paymentCategory = this.paymentCategory.Trim().Length == 0 ? this.PatientPaymentDefault : this.paymentCategory;

                bool enabled         = WConfiguration.LoadAndCache<bool>  (this.SiteID, "D|patmed", "GenericInterface", "PrintingInterface", false,          false);
                bool supportedKind   = WConfiguration.LoadAndCache<string>(this.SiteID, "D|GenInt", "GenericInterface", "TransKinds",        "IODL",         false).Contains(EnumDBCodeAttribute.EnumToDBCode(transKind ));
                bool supportedLabel  = WConfiguration.LoadAndCache<string>(this.SiteID, "D|GenInt", "GenericInterface", "TransLabels",       "IODLSPFMWXC",  false).Contains(EnumDBCodeAttribute.EnumToDBCode(transLabel));
                bool supportedPayment= this.PaymentFilter.Length == 0 || ("," + this.PaymentFilter + ",").Contains("," + paymentCategory + ",");

                return enabled && supportedKind && supportedLabel && supportedPayment;
            }
        }

        /// <summary>Gets RTF interface filename D|GenInt.TranslogInterface.RTFFile</summary>
        public string RTFFile { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", "RTFFile", string.Empty, false); } }

        /// <summary>Export path for the interface file D|GenInt.TranslogInterface.ExportFilePath</summary>
        public string ExportPath { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", "ExportFilePath", string.Empty, false); } }

        /// <summary>File pointer (or counter name) GenInt.TranslogInterface.InterfacePointerFile</summary>
        public string FilePointerName 
        { 
            get 
            { 
                string dispData = WConfiguration.LoadAndCache<string>(this.SiteID, "D|Siteinfo", string.Empty, "DispdataDRV", string.Empty, false);
                if (!dispData.EndsWith("\\"))
                    dispData += "\\";
                dispData = Path.Combine(dispData, string.Format("dispdata.{0:000}", Site2.GetSiteNumberByID(this.SiteID))) + "\\";
                
                return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", "InterfacePointerFile", "D|TransInt.dat", false).ToUpper().Replace(dispData.ToUpper(), "D|");
            } 
        }

        /// <summary>Filename prefix GenInt.TranslogInterface.FilePrefix</summary>
        public string FilePrefix { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", "FilePrefix", "T", false); } }

        /// <summary>Filename suffix GenInt.TranslogInterface.Filesuffix or FilesuffixReturn or FilesuffixIssue</summary>
        public string FileSuffix
        { 
            get
            {
                string suffix = WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", "Filesuffix", string.Empty, false);
                return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", this.isReturn ? "FilesuffixReturn" : "FilesuffixIssue", suffix, false); 
            }
        }

        /// <summary>Filename extension (default .xml) GenInt.TranslogInterface.OutputFileExtension</summary>
        public string FileExtension { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "TranslogInterface", "OutputFileExtension", ".xml", false); } }

        /// <summary>Payment interface filter GenInt.TranslogInterface.PaymentFilter</summary>
        public string PaymentFilter { get { return WConfiguration.LoadAndCache<string>(this.SiteID, "D|GenInt", "TranslogInterface", "PaymentFilter", string.Empty, false); } }

        /// <summary>Payment interface filter GenInt.TranslogInterface.PatientPaymentDefault</summary>
        public string PatientPaymentDefault { get { return WConfiguration.LoadAndCache<string>(this.SiteID, "D|GenInt", "TranslogInterface", "PatientPaymentDefault", "UNKNOWN", false); } }

        /// <summary>If using file batching GenInt.FileBatching.UseFileBatching</summary>
        public bool UseFileBatching { get { return WConfiguration.LoadAndCache<bool>(this.SiteID, "D|GenInt", "FileBatching", "UseFileBatching", false, false); } }

        /// <summary>If using file batching GenInt.FileBatching.BatchTotal</summary>
        public int BatchTotal { get { return WConfiguration.LoadAndCache<int>(this.SiteID, "D|GenInt", "FileBatching", "BatchTotal", 1, false); } }
    }
    
    /// <summary>Settings for the pharmacy stock interface (all of the setting come from WConfiguration mainly where Section='StockInterface') 24Jun16 XN 108889</summary>
    internal class StockInterfaceSettings : IPharmacyInterfaceSettings
    {
        public StockInterfaceSettings (int siteID)
	    {
            this.SiteID = siteID;
	    }

        /// <summary>Site ID the settings are for</summary>
        public int SiteID { get; private set; }

        /// <summary>If the supplier interface is enabled D|patmed.GenericInterface.SupplierInterface</summary>
        public bool Enabled { get { return WConfiguration.LoadAndCache<bool>(this.SiteID, "D|patmed", "GenericInterface", "StockInterface", false, false); } }

        /// <summary>Gets RTF interface filename D|GenInt.StockInterface.RTFFile</summary>
        public string RTFFile { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "StockInterface", "RTFFile", string.Empty, false); } }

        /// <summary>Export path for the interface file D|GenInt.SupplierInterface.ExportFilePath</summary>
        public string ExportPath { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "StockInterface", "ExportFilePath", string.Empty, false); } }

        /// <summary>File pointer (or counter name) GenInt.StockInterface.InterfacePointerFile</summary>
        public string FilePointerName 
        { 
            get 
            { 
                string dispData = WConfiguration.LoadAndCache<string>(this.SiteID, "D|Siteinfo", string.Empty, "DispdataDRV", string.Empty, false);
                if (!dispData.EndsWith("\\"))
                    dispData += "\\";
                dispData = Path.Combine(dispData, string.Format("dispdata.{0:000}", Site2.GetSiteNumberByID(this.SiteID))) + "\\";
                string value = WConfiguration.Load<string>(this.SiteID, "D|GenInt", "StockInterface", "InterfacePointerFile", Path.Combine(dispData, "SupInt"), false); 
                return value.Replace(dispData, "D|");
            } 
        }

        /// <summary>Filename prefix GenInt.StockInterface.FilePrefix</summary>
        public string FilePrefix { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "StockInterface", "FilePrefix", "O", false); } }

        /// <summary>Filename suffix GenInt.StockInterface.Filesuffix</summary>
        public string FileSuffix { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "StockInterface", "Filesuffix", string.Empty, false); } }

        /// <summary>Filename extension (default .xml) GenInt.StockInterface.OutputFileExtension</summary>
        public string FileExtension { get { return WConfiguration.Load<string>(this.SiteID, "D|GenInt", "StockInterface", "OutputFileExtension", ".xml", false); } }

        /// <summary>If using file batching GenInt.FileBatching.UseFileBatching</summary>
        public bool UseFileBatching { get { return WConfiguration.LoadAndCache<bool>(this.SiteID, "D|GenInt", "StockInterface", "UseFileBatching", false, false); } }

        /// <summary>If using file batching GenInt.FileBatching.BatchTotal</summary>
        public int BatchTotal { get { return WConfiguration.LoadAndCache<int>(this.SiteID, "D|GenInt", "StockInterface", "BatchTotal", 1, false); } }
    }
}
