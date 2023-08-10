using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

namespace ascribe.pharmacy.wardstocklistlayer
{
    internal static class XMLHeap
    {
        public static string WardStockListInfo(WWardProductListRow list)
        {
            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                xmlWriter.WriteAttributeString("sCode",       list.Code);
                xmlWriter.WriteAttributeString("sName", list.Description);
                xmlWriter.WriteAttributeString("sNameXML", list.Description.XMLEscape());
                xmlWriter.WriteAttributeString("sfullname", list.FullName.Trim());
                string fullnameTrim = list.FullName.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "FullnameTrim", 32, true));
                xmlWriter.WriteAttributeString("sfullnameTrim", fullnameTrim);
                xmlWriter.WriteAttributeString("sfullnameTrimXML", fullnameTrim.XMLEscape());       
                xmlWriter.WriteAttributeString("sPrintDelNote", list.PrintDeliveryNote.ToYNString());
                xmlWriter.WriteAttributeString("sPrintPickTick", list.PrintPickTicket.ToYNString());
                xmlWriter.WriteAttributeString("sInUse", list.InUse.ToYNString());

                var customer = list.GetCustomer();
                xmlWriter.WriteAttributeString("swardcode",    customer.Code);
                xmlWriter.WriteAttributeString("swardcodeXML", customer.Code.XMLEscape());

                xmlWriter.WriteAttributeString("sVisibleToWard", list.VisibleToWard.ToYNString());

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }
}
