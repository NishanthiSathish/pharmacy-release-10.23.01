//===========================================================================
//
//						 SearchAndReplaceProcessor.cs
//
//  Ward stock list search and replce processor.
//
//  Processor will perform either a search and replace/update/delete on ward stock list lines. 
//  The operation to perform depends the which constructor is called.
//
//  Search and update operation is a bit odd as most of the work is done by 
//  QSProcessor calss that is passed in
//  
//  The processor can perform follownig operations
//      Generate HTML for action to perform
//      Generate report for action to perform
//      Perform replace/update/delete action
//  
//	Modification History:
//	09Jul14 XN  Written
//  17Dec14 XN  Added Search and Update operation 
//              Removed quatity and print label from search and replace 38034
//  19Dec14 XN  Replace the replace to add and delete.
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.wardstocklistlayer
{
    public class SearchAndReplaceProcessor
    {
        #region Data Types
        /// <summary>Processord mode if performing replace or delete</summary>
        private enum Mode
        {
            Replace,
            Update,
            Delete
        }
        #endregion

        #region Variables
        /// <summary>NSVCode of product to search for</summary>
        private string searchNSVCode;

        /// <summary>NSVCode of product to replace (can be null)</summary>
        private string replaceNSVCode;

        /// <summary>New description</summary>
        private string newDescription;

        /// <summary>New pack size</summary>
        private int newPackSize;

        /// <summary>List of wards to update</summary>
        private int[] wardStockListIDs;

        /// <summary>Search and replace mode</summary>
        private Mode mode;

        /// <summary>List of all sites</summary>
        private IEnumerable<Site> sites;

        /// <summary>Accessor for QS processor (when doing find and update)</summary>
        private WWardProductListLineAccessor accessor;

        /// <summary>QS View (when doing find and update)</summary>
        private QSView qsview;
        #endregion

        #region Constructors
        /// <summary>Constructor for search and reaplce</summary>
        public SearchAndReplaceProcessor(string searchNSVCode, 
                                         string replaceNSVCode,
                                         string newDescription,
                                         int    newPackSize,
                                         int[] wardStockListIDs)
        {
            this.searchNSVCode         = searchNSVCode;
            this.replaceNSVCode        = replaceNSVCode;        
            this.newDescription        = newDescription;        
            this.newPackSize           = newPackSize;           
            this.wardStockListIDs      = wardStockListIDs;      
            this.mode                  = Mode.Replace;
            this.sites                 = (new SiteProcessor()).LoadAll();
        }
        
        /// <summary>Constructor for search and update 17Dec15 XN 38034</summary>
        public SearchAndReplaceProcessor(string searchNSVCode, WWardProductListLineAccessor accessor, QSView qsview)
        {
            this.searchNSVCode   = searchNSVCode;
            this.accessor        = accessor;
            this.qsview          = qsview;
            this.mode            = Mode.Update;
            this.sites           = (new SiteProcessor()).LoadAll();

            // Filter to just list that will be updated
            this.wardStockListIDs= (from diff in accessor.GetDifferences(qsview)
                                    join l    in accessor.Lines on diff.siteID equals l.WWardProductListLineID  // Is correct as using siteID as WWardProductListLineID
                                    select l.WWardProductListID).ToArray();
        }

        /// <summary>Constructor for search and delete</summary>
        public SearchAndReplaceProcessor(string searchNSVCode, int[] wardStockListIDs)
        {
            this.searchNSVCode    = searchNSVCode;
            this.wardStockListIDs = wardStockListIDs;      
            this.mode             = Mode.Delete;
            this.sites            = (new SiteProcessor()).LoadAll();
        }
        #endregion

        #region Public methods
        /// <summary>Returns the HTML info message about the operation to be performed</summary>
        public string GenerateHTMLInfo()
        {
            StringBuilder str = new StringBuilder();

            // Load up all lists
            WWardProductList wardProductList = new WWardProductList();
            wardProductList.LoadBySiteAndNSVCode(SessionInfo.SiteID, this.searchNSVCode);

            // Set operation header
            switch (this.mode)
            {
            case Mode.Replace: 
                str.Append( GenerateReplaceHeaderInfo());
                break;
            case Mode.Update:  
                str.AppendFormat("Will update the following item\n\t{0}\nfor\n\n", WProduct.ProductDetails(searchNSVCode, SessionInfo.SiteID));
                str.Append( this.accessor.GetDifferences(this.qsview).ToHTML() ); 
                break; 
            case Mode.Delete:
                str.Append( GenerateDeleteHeaderInfo() );
                break;
            }

            if (this.mode != Mode.Update)
            {
                // List wards being update
                str.Append("\nOn following stock lists:\n");
                str.Append("<asp:Panel runat='server' ScrollBars='Vertical' Height='100px'>");
                str.Append( GenerateListInfo(wardProductList.FindByIDs(this.wardStockListIDs)).ToCSVString("\n") );
                str.Append("</asp:Panel>");

                // List wards not being update
                var wardsNotUpdated = GenerateListInfo(wardProductList.Where(l => !this.wardStockListIDs.Contains(l.WWardProductListID)));
                if (wardsNotUpdated.Any())
                {
                    str.Append("\n\nThe following stock lists are not affected:\n");
                    str.Append("<asp:Panel runat='server' ScrollBars='Vertical' Height='100px'>");
                    str.Append( wardsNotUpdated.ToCSVString("\n") );
                    str.Append("</asp:Panel>");
                }
            }

            return str.Replace("\n", "<br />").Replace("\t", "&nbsp;&nbsp;&nbsp;").ToString();
        }

        /// <summary>
        /// Saves RTF report (of the operation) to session attribute PharmacyGeneralReportAttribute 
        /// (should be done before operatino is performed)
        /// </summary>
        public void SaveReport()
        {
            // Get site data
            Site site = sites.First(s => s.Number == SessionInfo.SiteNumber);
            DateTime now = DateTime.Now;

            WWardProductList wardProductList = new WWardProductList();
            wardProductList.LoadBySiteAndNSVCode(SessionInfo.SiteID, this.searchNSVCode);

            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("PNPrintData");

                // Report title
                xmlWriter.WriteStartElement("Title");
                switch (this.mode)
                {
                case Mode.Replace: xmlWriter.WriteAttributeString("title", "Replace Ward Stock List Items"); break;
                case Mode.Update:  xmlWriter.WriteAttributeString("title", "Update Ward Stock List Items" ); break;
                case Mode.Delete:  xmlWriter.WriteAttributeString("title", "Delete Ward Stock List Items" ); break;
                }
                xmlWriter.WriteEndElement();

                // Hospital name
                xmlWriter.WriteStartElement("Info");
                xmlWriter.WriteAttributeString("hospname1", site.FullName       );
                xmlWriter.WriteAttributeString("hospname2", site.AccountName    );
                xmlWriter.WriteAttributeString("hospname3", site.AbbreviatedName);

                // User info
                xmlWriter.WriteAttributeString("UserID",   SessionInfo.UserInitials);
                xmlWriter.WriteAttributeString("UserName", SessionInfo.Username    );
                xmlWriter.WriteAttributeString("today",    now.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("TimeNow",  now.ToPharmacyTimeString());
                xmlWriter.WriteEndElement();

                // Build up text (use RTF table so easy to create RTF each line new row)
                RTFTable table = new RTFTable();
                table.AddColumn(string.Empty, 100, RTFTable.AlignmentType.Left);
                
                // Add header
                string info      = string.Empty;
                string extraInfo = string.Empty;
                switch (this.mode)
                {
                case Mode.Replace: 
                    info = GenerateReplaceHeaderInfo();
                    break;
                case Mode.Update : 
                    info      =  string.Format("Will update the following item\n\t{0}\nfor\n\n", WProduct.ProductDetails(searchNSVCode, SessionInfo.SiteID));
                    extraInfo = (this.accessor.GetDifferences(this.qsview) as QSDifferencesListForLine).ToRTF();
                    break;
                case Mode.Delete : 
                    info = GenerateDeleteHeaderInfo();
                    break;
                }

                foreach (string line in info.Split(new [] { '\n' }))
                {
                    table.NewRow();
                    table.AddCell(line.Replace( "\t",  "   "));
                }

                // Add ward detials
                if (this.mode != Mode.Update)
                {
                    // Display list of wards to update
                    table.NewRow();
                    table.AddCell("\nOn following stock lists:\n");
                    foreach (string line in GenerateListInfo(wardProductList.FindByIDs(this.wardStockListIDs)))
                    {
                        table.NewRow();
                        table.AddCell(line.Replace( "\t",  "   "));
                    }
                    table.NewRow();

                    // Display list of wards not to update
                    var wardsNotUpdated = GenerateListInfo(wardProductList.Where(l => !this.wardStockListIDs.Contains(l.WWardProductListID)));
                    if (wardsNotUpdated.Any())
                    {
                        table.NewRow();
                        table.AddCell("\nThe following stock lists are not affected:\n");
                        foreach (string line in wardsNotUpdated)
                        {
                            table.NewRow();
                            table.AddCell(line.Replace( "\t",  "   "));
                        }
                    }
                }

                // save data
                xmlWriter.WriteStartElement("Data");
                xmlWriter.WriteAttributeString("Table", table.ToString() + extraInfo ); // XML escape as 
                xmlWriter.WriteEndElement();

                xmlWriter.WriteEndElement();

                xmlWriter.Close();
            }

            // Save
            SessionInfo.SaveAttribute("PharmacyGeneralReportAttribute", xml.ToString());
        }

        /// <summary>Performs the relative delete or replace action depening on the constructor called</summary>
        public void PerformAction()
        {
            using (WWardProductList list = new WWardProductList())
            {
                // load and lock list
                list.RowLockingOption = LockingOption.HardLock;
                list.LoadByIDs(wardStockListIDs);

                // Have hard locked but check for any soft lock
                IDictionary<int,LockException> softLocks = (new SoftLockResults(list.TableName)).IsLockedByOtherUser(wardStockListIDs);
                if (softLocks.Any())
                    throw softLocks.First().Value;

                switch (this.mode)
                {
                case Mode.Replace:  // perform replace
                    {
                    // Load lines
                    WWardProductListLine lines = new WWardProductListLine();
                    lines.LoadByNSVCodeAndSite(searchNSVCode, SessionInfo.SiteID);

                    WProductRow replaceProduct = WProduct.GetByProductAndSiteID(this.replaceNSVCode, SessionInfo.SiteID);

                    // Does a delete and re-add for selected lines
                    foreach (var l in lines.Where(l => wardStockListIDs.Contains(l.WWardProductListID)).ToList())
                    {                    
                        // Create new line to replace existing line
                        var newRow = lines.Add(replaceProduct);
                        newRow.ClearIssuingFields();
                        newRow.NSVCode                          = this.replaceNSVCode;
                        newRow.Description                      = this.newDescription;
                        newRow.DisplayIndex                     = l.DisplayIndex;
                        newRow.ConversionFactorPackToIssueUnits = this.newPackSize;
                        newRow.PrintLabel                       = l.PrintLabel;
                        newRow.WWardProductListID               = l.WWardProductListID;
                        newRow.TopupLvl                         = l.TopupLvl;
                        newRow.Comment                          = l.Comment;

                        // Delete old line
                        lines.Remove(l);
                    }
                    lines.Save(list);
                    }
                    break;
                case Mode.Update:   // perform update all handled by QuesScrol
                    accessor.Save(qsview, true);
                    break;
                case Mode.Delete:   // perform delete
                    {
                    // Load lines
                    WWardProductListLine lines = new WWardProductListLine();
                    lines.LoadByNSVCodeAndSite(searchNSVCode, SessionInfo.SiteID);

                    // Delete lines for selected lists
                    lines.RemoveAll(l => wardStockListIDs.Contains(l.WWardProductListID));
                    lines.Save(list);
                    }
                    break;
                }            
            }
        }
        #endregion

        #region Private Methods
        /// <summary>Generate the info text header for the replace action</summary>
        private string GenerateReplaceHeaderInfo()
        {
            // Get search for, and replace with products
            WProductRow searchProduct  = WProduct.GetByProductAndSiteID(searchNSVCode, SessionInfo.SiteID);
            WProductRow replaceProduct = null;
            if (!string.IsNullOrEmpty(replaceNSVCode))
                replaceProduct = WProduct.GetByProductAndSiteID(replaceNSVCode, SessionInfo.SiteID);

            // Build up the message of what is going to happen
            StringBuilder str = new StringBuilder();
            str.Append(replaceProduct == null ? "Update " : "Replace ");
            str.AppendFormat(" {0} - {1}\n", searchProduct.NSVCode, searchProduct.ToString());

            if (replaceProduct != null)
            {
                str.Append("\nwith ");
                str.AppendFormat(" {0} - {1}\n", replaceProduct.NSVCode, replaceProduct.ToString());
            }

            StringBuilder replaceItems = new StringBuilder();
            replaceItems.AppendFormat("Set description to {0}\n", newDescription);
            replaceItems.AppendFormat("Set pack size to {0}\n",   newPackSize);
            if (replaceItems.Length > 0)
            {
                str.Append("\n");
                str.Append(replaceItems);
            }

            return str.ToString();
        }


        /// <summary>Generate the info text header for the delete action</summary>
        private string GenerateDeleteHeaderInfo()
        {
            WProductRow searchProduct  = WProduct.GetByProductAndSiteID(searchNSVCode, SessionInfo.SiteID);
            return string.Format("Delete {0} - {1}\n", searchProduct.NSVCode, searchProduct.ToString());
        }

        /// <summary>Convert the list of wars to a list of ward names as Code - Description (site number)</summary>
        private IEnumerable<string> GenerateListInfo(IEnumerable<WWardProductListRow> wardStockLists)
        {
            foreach (var l in wardStockLists.OrderBy(s => s.Code))
                yield return string.Format("\t{0} - {1}", l.Code, l.Description );
        }
        #endregion
    }
}
