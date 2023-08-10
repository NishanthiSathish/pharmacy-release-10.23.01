//===========================================================================
//
//							DataSet2Recordset.cs
//
//  This class converts an ADO.net dataset into an XML representation
//  of an ADODB recordset.
//
//	Modification History:
//	31Aug12 AJK  Written
//  07Sep12 CKJ Added Single & Double to GetDatatype. 
//    See caveats in routine - should handle all persistable data types
//    MS document [MS-PRSTFR].pdf in MS Office Open Specifications Documentation
//    http://msdn.microsoft.com/en-us/library/dd960864%28v=office.12%29
//    http://download.microsoft.com/download/1/6/F/16F4E321-AA6B-4FA3-8AD3-E94C895A3C97/OfficeProto.zip
//  12Sep12 AJK 43644 GetDatatype: Added boolean handling
//  17Sep12 AJK 44028 WriteSchema: Remove any offset from datatime as ADO isn't overly keen
//  30Sep12 CKJ 44486 TransformData: Re-encode control chars in XML stream
//===========================================================================
using Microsoft.VisualBasic;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;
using System.IO;
using System.Text;

namespace ascribe.pharmacy.shared
{
    /// <summary>
    /// Class to convert ADO.net DataSet to XML representation of an ADODB recordset
    /// </summary>
    public static class DataSet2Recordset
    {
        /// <summary>
        /// Takes a DataSet and converts into a Recordset. The converted ADODB recordset is saved as an XML file. The data is saved to the file path passed as parameter.
        /// </summary>
        /// <param name="ds">DataSet object</param>
        /// <param name="dbname">Database Name</param>
        /// <param name="xslfile">XSLT transform file location for ADODO recordset definition conversion</param>
        /// <param name="outputfile">String output</param>
        /// <returns></returns>
        public static long GetADORS(DataSet ds, string dbname, string xslfile, out string outputfile)
        {
            //Create an xmlwriter object, to write the ADO Recordset Format XML
            try
            {
                StringWriter sw = new StringWriter();
                XmlTextWriter xwriter = new XmlTextWriter(sw);


                //call this Sub to write the ADONamespaces to the XMLTextWriter
                WriteADONamespaces(ref xwriter);
                //call this Sub to write the ADO Recordset Schema
                WriteSchemaElement(ds, dbname, ref xwriter);

                MemoryStream TransformedDatastrm = new MemoryStream();
                //Call this Function to transform the Dataset xml to ADO Recordset XML
                TransformedDatastrm = TransformData(ds, xslfile);
                //Pass the Transformed ADO Recordset XML to this Sub
                //to write in correct format.
                HackADOXML(ref xwriter, TransformedDatastrm);
                xwriter.Flush();
                xwriter.Close();
                outputfile = sw.ToString();
                //returns 1 if success
                return 1;

            }
            catch (Exception ex)
            {
                outputfile = ex.Message;
                return 0;
            }
        }

        /// <summary>
        /// Writes the ADO namespace info
        /// </summary>
        /// <param name="writer">XML writer</param>
        private static void WriteADONamespaces(ref XmlTextWriter writer)
        {
            //The following is to specify the encoding of the xml file
            //writer.WriteProcessingInstruction("xml", "version='1.0' encoding='ISO-8859-1'")

            //The following is the ado recordset format
            //<xml xmlns:s='uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882' 
            //        xmlns:dt='uuid:C2F41010-65B3-11d1-A29F-00AA00C14882'
            //        xmlns:rs='urn:schemas-microsoft-com:rowset' 
            //        xmlns:z='#RowsetSchema'>
            //    </xml>

            //Write the root element
            writer.WriteStartElement("", "xml", "");

            //Append the ADO Recordset namespaces
            writer.WriteAttributeString("xmlns", "s", null, "uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882");
            writer.WriteAttributeString("xmlns", "dt", null, "uuid:C2F41010-65B3-11d1-A29F-00AA00C14882");
            writer.WriteAttributeString("xmlns", "rs", null, "urn:schemas-microsoft-com:rowset");
            writer.WriteAttributeString("xmlns", "z", null, "#RowsetSchema");
            writer.Flush();

        }


        /// <summary>
        /// Writes the Schema element
        /// </summary>
        /// <param name="ds">Dataset object</param>
        /// <param name="dbname">Database name</param>
        /// <param name="writer">XMLWriter object</param>
        private static void WriteSchemaElement(DataSet ds, string dbname, ref XmlTextWriter writer)
        {
            //ADO Recordset format for defining the schema
            // <s:Schema id='RowsetSchema'>
            //            <s:ElementType name='row' content='eltOnly' rs:updatable='true'>
            //            </s:ElementType>
            //        </s:Schema>

            //write element schema
            writer.WriteStartElement("s", "Schema", "uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882");
            writer.WriteAttributeString("id", "RowsetSchema");

            //write element ElementTyoe
            writer.WriteStartElement("s", "ElementType", "uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882");

            //write the attributes for ElementType
            writer.WriteAttributeString("name", "", "row");
            writer.WriteAttributeString("content", "", "eltOnly");
            writer.WriteAttributeString("rs", "updatable", "urn:schemas-microsoft-com:rowset", "true");

            WriteSchema(ds, dbname, ref writer);
            //write the end element for ElementType
            writer.WriteFullEndElement();

            //write the end element for Schema 
            writer.WriteFullEndElement();
            writer.Flush();
        }


        /// <summary>
        /// WRites the schema info
        /// </summary>
        /// <param name="ds">Dataset object</param>
        /// <param name="dbname">Database name</param>
        /// <param name="writer">XMLWriter</param>
        private static void WriteSchema(DataSet ds, string dbname, ref XmlTextWriter writer)
        {
            Int32 i = 1;
            DataColumn dc = null;


            foreach (DataColumn dc_loopVariable in ds.Tables[0].Columns)
            {
                // 17Sep12 AJK 44028 Remove any offset from datatime as ADO isn't overly keen
                if (dc_loopVariable.DataType == typeof(System.DateTime))
                {
                    dc_loopVariable.DateTimeMode = DataSetDateTime.Unspecified;
                }
                
                dc = dc_loopVariable;
                dc.ColumnMapping = MappingType.Attribute;

                writer.WriteStartElement("s", "AttributeType", "uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882");
                //write all the attributes 
                writer.WriteAttributeString("name", "", dc.ToString());
                writer.WriteAttributeString("rs", "number", "urn:schemas-microsoft-com:rowset", i.ToString());
                writer.WriteAttributeString("rs", "baseCatalog", "urn:schemas-microsoft-com:rowset", dbname);
                writer.WriteAttributeString("rs", "baseTable", "urn:schemas-microsoft-com:rowset", dc.Table.TableName.ToString());
                writer.WriteAttributeString("rs", "keycolumn", "urn:schemas-microsoft-com:rowset", dc.Unique.ToString());
                writer.WriteAttributeString("rs", "autoincrement", "urn:schemas-microsoft-com:rowset", dc.AutoIncrement.ToString());
                //write child element
                writer.WriteStartElement("s", "datatype", "uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882");
                //write attributes
                writer.WriteAttributeString("dt", "type", "uuid:C2F41010-65B3-11d1-A29F-00AA00C14882", GetDatatype(dc.DataType.ToString()));
                writer.WriteAttributeString("dt", "maxlength", "uuid:C2F41010-65B3-11d1-A29F-00AA00C14882", dc.MaxLength.ToString());
                writer.WriteAttributeString("rs", "maybenull", "urn:schemas-microsoft-com:rowset", dc.AllowDBNull.ToString());
                //write end element for datatype
                writer.WriteEndElement();
                //end element for AttributeType
                writer.WriteEndElement();
                writer.Flush();
                i = i + 1;
            }
            dc = null;

        }


        /// <summary>
        /// Gets the ADO compatible datatype
        /// </summary>
        /// <param name="dtype">ADO.net datatype</param>
        /// <returns>ADO datatype</returns>
        private static string GetDatatype(string dtype)
        {
            switch (dtype)
            {   
                case "System.Int32":
                    return "int";
                case "System.DateTime":
                    return "dateTime";
                case "System.Single":   //07Sep12 CKJ Added Single & Double.
                    return "float";     // Design would be better using enums not plain text
                case "System.Double":   // and should have complete set of data types, eg
                    return "float";     // guid, boolean, various strings, int16/64
                case "System.Boolean":  // 12Sep12 AJK 43644 Added boolean handling
                    return "boolean";   // 12Sep12 AJK 43644 Added boolean handling
                default:
                    return string.Empty;
            }
        }


        /// <summary>
        /// Transform the data set format to ADO Recordset format. This only transforms the data.
        /// </summary>
        /// <param name="ds">Dataset object</param>
        /// <param name="xslfile">XSLFile location</param>
        /// <returns>MemoryStream of XML data</returns>
        private static MemoryStream TransformData(DataSet ds, string xslfile)
        {
            MemoryStream instream = new MemoryStream();
            MemoryStream midstream = new MemoryStream();
            MemoryStream outstream = new MemoryStream();

            //write the xml into a memorystream
            ds.WriteXml(instream, XmlWriteMode.IgnoreSchema);

            //load the xsl document
            XslTransform xslt = new XslTransform();
            xslt.Load(xslfile);

            //create the xmltextreader using the memory stream
            instream.Position = 0;
            XmlTextReader xmltr = new XmlTextReader(instream);
            //create the xpathdoc
            XPathDocument xpathdoc = new XPathDocument(xmltr);

            //create XpathNavigator
            XPathNavigator nav = null;
            nav = xpathdoc.CreateNavigator();

            //Create the XsltArgumentList.
            XsltArgumentList xslArg = new XsltArgumentList();

            //Create a parameter that represents the current date and time.
            xslArg.AddParam("tablename", "", ds.Tables[0].TableName);

            //transform the xml to a memory stream
            xslt.Transform(nav, xslArg, midstream);

            //30Sep12 CKJ added block and use of midstream above (TFS44486)
            //At this point, any invalid chars (0-31 except 9/10/13) have been changed back from eg &#x1F; to a single unescaped char 31.
            //Now need to re-encode them back to &#xHH;
            //Method below is not efficient, but adequate as a proof of concept.
            midstream.Position = 0;
            outstream.Position = 0;
            for (int counter = 0; counter < midstream.Length; counter++)
            {
                int ch = midstream.ReadByte();
                if (ch < 32 && ch != 9 && ch != 10 && ch != 13)             //replace char with &#xNN; where NN is hex value
                {
                    outstream.WriteByte(38);                                //&
                    outstream.WriteByte(35);                                //#
                    outstream.WriteByte(120);                               //x
                    outstream.WriteByte(Convert.ToByte(48 + (ch / 16 )));   //0 or 1
                    ch = ch % 16;
                    if (ch<10)
                    {
                        outstream.WriteByte(Convert.ToByte(48 + ch));       //0 to 9
                    }
                    else
                    {
                        outstream.WriteByte(Convert.ToByte(55 + ch));       //A TO F
                    }
                    outstream.WriteByte(59);                                //;
                }
                else
                {
                    outstream.WriteByte(Convert.ToByte(ch));
                }
            }
            
            instream = null;        //** these look to be left over from an automated vb=>c# converter & could be tidied when the code is next edited.
            xslt = null;
            xpathdoc = null;
            nav = null;

            return outstream;
        }

        /// <summary>
        /// The XSLT does not transform with fullendelements. ADO Recordset cannot read this. This method is used to convert the elements to have fullendelements.
        /// </summary>
        /// <param name="wrt">XMLTextWriter</param>
        /// <param name="ADOXmlStream">MemoryStream of ADO data XML</param>
        private static void HackADOXML(ref XmlTextWriter wrt, System.IO.MemoryStream ADOXmlStream)
        {
            ADOXmlStream.Position = 0;
            XmlTextReader rdr = new XmlTextReader(ADOXmlStream);
            MemoryStream outStream = new MemoryStream();
            //Dim wrt As New XmlTextWriter(outStream, System.Text.Encoding.Default)

            rdr.MoveToContent();
            //if the ReadState is not EndofFile, read the XmlTextReader for nodes.
            while (rdr.ReadState != ReadState.EndOfFile)
            {
                if (rdr.Name == "s:Schema")
                {
                    wrt.WriteNode(rdr, false);
                    wrt.Flush();
                }
                else if (rdr.Name == "z:row" & rdr.NodeType == XmlNodeType.Element)
                {
                    wrt.WriteStartElement("z", "row", "#RowsetSchema");
                    rdr.MoveToFirstAttribute();
                    wrt.WriteAttributes(rdr, false);
                    wrt.Flush();
                }
                else if (rdr.Name == "z:row" & rdr.NodeType == XmlNodeType.EndElement)
                {
                    //The following is the key statement that closes the z:row 
                    //element without generating a full end element
                    wrt.WriteEndElement();
                    wrt.Flush();
                }
                else if (rdr.Name == "rs:data" & rdr.NodeType == XmlNodeType.Element)
                {
                    wrt.WriteStartElement("rs", "data", "urn:schemas-microsoft-com:rowset");
                }
                else if (rdr.Name == "rs:data" & rdr.NodeType == XmlNodeType.EndElement)
                {
                    wrt.WriteEndElement();
                    wrt.Flush();
                }
                rdr.Read();
            }

            wrt.WriteEndElement();
            wrt.Flush();
        }

    }
}
