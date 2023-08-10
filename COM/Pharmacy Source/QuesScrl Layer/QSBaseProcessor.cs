//===========================================================================
//
//							    QSBaseProcessor.cs
//
//  Base class for a QuesScrl processor.
//
//  The processors provide a way of mapping the QuesScrl data index (from WConfiguration), to db fields.
//  
//  For more information see QuesScrl.ascx.cs
//
//	Modification History:
//	23Jan14 XN  Written
//  16Jun14 XN  Updated Create as moved WProductQSProcessor, and WSupplierQSProcessor
//              to Pharmacy data layer
//  25Jun14 XN  Added WSupplier2Accessor to Create method 88506
//  16Oct14 XN  102114 Changed GetRequiredDataIndexes so reutrn list of items 
//              that are force to mandatory
//  17Dec15 XN  Added WWardProductListLineAccessor 38034
//===========================================================================
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;
using System.IO.Compression;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Base class for a QuesScrl Processor</summary>
    public abstract class QSBaseProcessor
    {
        #region Public properties
        /// <summary>List of supported site IDs</summary>
        public IEnumerable<int> SiteIDs { get; set; }
        #endregion

        public QSBaseProcessor(IEnumerable<int> siteIDs)
        {
            this.SiteIDs = siteIDs == null ? null : siteIDs.ToList();
        }

        #region Public Methods
        /// <summary>Converts the data in the process to XML (for storage on web page)</summary>
        public string WriteXml()
        {
            // Setup to write xml fragment
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.Indent             = false;
            settings.OmitXmlDeclaration = true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // 27Jan14 XN Replaced to add compression
            //// Write xml string
            //StringBuilder str = new StringBuilder();
            //using(XmlWriter writer = XmlWriter.Create(str, settings))
            //{
            //    this.WriteXml(writer);
            //    writer.Flush();
            //    writer.Close();
            //}

            // Write xml
            using (MemoryStream memStream = new MemoryStream())
            {
                using(DeflateStream comp = new DeflateStream(memStream, CompressionMode.Compress, true))
                {
                    using(XmlWriter writer = XmlWriter.Create(comp, settings))
                    {
                        this.WriteXml(writer);
                        writer.Flush();
                        writer.Close();
                    }

                    comp.Flush();
                    comp.Close();
                }

                return Convert.ToBase64String(memStream.GetBuffer(), 0, (int)memStream.Length);
            }
        }

        /// <summary>Reads xml create from WriteXml to object (for storage on web page)</summary>
        public void ReadXml(string xml)
        {
            if (string.IsNullOrEmpty(xml))
                return;

            // Setup string as XML fragment
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ConformanceLevel = ConformanceLevel.Fragment;

            // 27Jan14 XN Replaced to add compression
            // Read xml string
            //using (XmlReader reader = XmlReader.Create(new StringReader(xml), settings))
            //    ReadXml(reader);

            // Read xml string
            using (MemoryStream memStream = new MemoryStream(Convert.FromBase64String(xml)))
            {
                using(DeflateStream comp = new DeflateStream(memStream, CompressionMode.Decompress))
                {
                    memStream.Position = 0;
                    using (XmlReader reader = XmlReader.Create(comp, settings))
                    {
                        reader.Read();  // Read to first node
                        ReadXml(reader);
                    }
                }
            }
        }
        #endregion

        #region Public Static Methods
        /// <summary>Factory method to create a QSBaseProcessor of correct type from XML data created using WriteXml</summary>
        /// <param name="xml">XML data created using WriteXml</param>
        public static QSBaseProcessor Create(string xml)
        {
            QSBaseProcessor processor = null;

            // Setup string as XML fragment
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ConformanceLevel = ConformanceLevel.Fragment;

            //// Read xml 27Jun14 XN string repalced with conpression
            //using (XmlReader reader = XmlReader.Create(new StringReader(xml), settings))
            //{

            // Read xml string
            using (MemoryStream memStream = new MemoryStream(Convert.FromBase64String(xml)))
            {
                using(DeflateStream comp = new DeflateStream(memStream, CompressionMode.Decompress))
                {
                    memStream.Position = 0;
                    using (XmlReader reader = XmlReader.Create(comp, settings))
                    {
                        string type = reader.ReadElementString("Type");
                        switch (type)
                        {
                        case "WProductQSProcessor"          : processor = (Activator.CreateInstance("Pharmacy Data Layer",  "ascribe.pharmacy.pharmacydatalayer.WProductQSProcessor"          ).Unwrap() as QSBaseProcessor); break;
                        case "WSupplierProfileQSProcessor"  : processor = (Activator.CreateInstance("Pharmacy Data Layer",  "ascribe.pharmacy.pharmacydatalayer.WSupplierProfileQSProcessor"  ).Unwrap() as QSBaseProcessor); break;
                        case "WCustomerAccessor"            : processor = (Activator.CreateInstance("Pharmacy Data Layer",  "ascribe.pharmacy.pharmacydatalayer.WCustomerAccessor"            ).Unwrap() as QSBaseProcessor); break;
                        case "WWardProductListQSProcessor"  : processor = (Activator.CreateInstance("Ward Stock List Layer","ascribe.pharmacy.wardstocklistlayer.WWardProductListQSProcessor" ).Unwrap() as QSBaseProcessor); break;
                        case "WSupplier2Accessor"           : processor = (Activator.CreateInstance("Pharmacy Data Layer",  "ascribe.pharmacy.pharmacydatalayer.WSupplier2Accessor"           ).Unwrap() as QSBaseProcessor); break; // 25Jun14 XN  Added WSupplier2Accessor 88506
                        case "WWardProductListLineAccessor" : processor = (Activator.CreateInstance("Ward Stock List Layer","ascribe.pharmacy.wardstocklistlayer.WWardProductListLineAccessor").Unwrap() as QSBaseProcessor); break;
                        default:
                            throw new ApplicationException(string.Format("Your accessor class {0} has not been added to the QSBaseProcessor.Create factory method", type)); // 25Jun14 XN  Added better error message 88506
                        }
                        //if (typeof(WProductQSProcessor).Name == type)
                        //    processor = new WProductQSProcessor();
                        //else if (typeof(WSupplierProfileQSProcessor).Name == type)
                        //    processor = new WSupplierProfileQSProcessor();
                        //else if ("WWardProductListQSProcessor" == type)
                        //    processor = (Activator.CreateInstance("Ward Stock List Layer", "ascribe.pharmacy.wardstocklistlayer.WWardProductListQSProcessor").Unwrap() as QSBaseProcessor);
                    }
                }
            }

            processor.ReadXml(xml);   
            
            return processor;
        }
        #endregion

        #region Overridden Methods
        /// <summary>
        /// Returns a list of data field indexes whose values must be filled in by user
        /// Override to provide the list
        /// </summary>
        virtual public HashSet<int> GetRequiredDataIndexes(QSView qsView)
        {
            return new HashSet<int>( qsView.Where(d => d.ForceMandatory).Select(d => d.index) );
        }
        // abstract public HashSet<int> GetRequiredDataIndexes(); 102114 Changed GetRequiredDataIndexes so reutrn list of items that are force to mandatory

        /// <summary>
        /// Called to update qsView with all the values (from processor data)
        /// Override to call populate qs with corrrect data
        /// </summary>
        abstract public void PopulateForEditor(QSView qsView);

        /// <summary>
        /// Call to setup all the lookups in QSView
        /// Override to setup the lookup items
        /// </summary>
        abstract public void SetLookupItem(QSView qsView);

        /// <summary>
        /// Called to validate the web controls in QSView
        /// Override to perfrom the validation
        /// </summary>
        /// <returns>Returns list of validation error or warnings</returns>
        abstract public QSValidationList Validate(QSView qsView);

        /// <summary>
        /// Called to get difference between QS data and (original) process data
        /// Override to compare correct data to qs items
        /// </summary>
        abstract public QSDifferencesList GetDifferences(QSView qsView);

        /// <summary>Save the values from QSView to the DB (or just localy)</summary>
        /// <param name="qsView">QueScrl controls that hold the data</param>
        /// <param name="saveToDB">If the qsView data is to be saved to the DB (or just updated local data)</param>
        abstract public void Save(QSView qsView, bool saveToDB);

        /// <summary>Called when QS data time button is clicked</summary>
        /// <param name="qsView">QueScrl controls</param>
        /// <param name="index">Index of the button clicked</param>
        /// <param name="siteID">site ID</param>
        virtual public void ButtonClickEvent(QSView qsView, int index, int siteID) { }

        /// <summary>
        /// Writes object data to XML writer
        /// Override to write any processor specific data
        /// </summary>
        virtual public void WriteXml(XmlWriter writer)
        {
            writer.WriteElementString("Type",    this.GetType().Name);
            writer.WriteElementString("SiteIDs", SiteIDs.ToCSVString(","));
        }

        /// <summary>
        /// Reads object data from XML reader
        /// Override to read any processor specific data
        /// </summary>
        virtual public void ReadXml(XmlReader reader)
        {
            reader.ReadElementString("Type");
            this.SiteIDs = reader.ReadElementString("SiteIDs").ParseCSV<int>(",", false).ToList();
        }
        #endregion
    }
}
