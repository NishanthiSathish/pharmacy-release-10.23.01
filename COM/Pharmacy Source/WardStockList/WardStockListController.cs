//===========================================================================
//
//						 WardStockListController.cs
//
//  Ward stock list control.
//
//  As with most controller classes the class will be converted to a javascript 
//  object (using JSON) so changes to property names will require updating javascripts.
//  The class will also store larger data structures to the DB Session cache
//  so this is controlled by methods
//      Create          - to create object from JSON string
//      LoadFromCache   - to load data from session cache
//      SaveToCache     - to save data to session cache
//
//  Ward Stock list will support both hard and soft locking.
//  When soft locked the user can use the list (issue and return) - set when list is opened
//  When hard locked the user can edit the list
//  Many user can have a soft lock on a list (as no one has a hard list lock)
//  but only 1 user can have a hard lock on the list
//
//  Handles processes related to the WardStockList editor.
//  
//	Modification History:
//	08Jan14 XN  Written
//  01Apr15 XN  Added constant UrlParameterEscapeChar 115152
//  27Jul15 XN  IsSelectedLinesContiguous: filter out lines without valid NSVCodes (as not displayed in list)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Xml;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace ascribe.pharmacy.wardstocklistlayer
{
    /// <summary>mode for the editor (e.g. view only, editable) comes from desktop parameter</summary>
    public enum WardStockListMode
    {
        /// <summary>If editor is in view only mode</summary>
        ViewOnly,

        /// <summary>If editor is in tempory edit mode</summary>
        TemporaryEdit,

        /// <summary>If edotr allows editing (though list will still need to be locked to edit)</summary>
        Editable
    }

    public class WardStockListController
    {
        #region Constants
        /// <summary>Escape char used when this control object is converted to a JSON string and passed in as a window parameter  115152 XN 1Apr15</summary>
        public static readonly string UrlParameterEscapeChar = "!2E!";
        #endregion

        #region Fields
        /// <summary>List of products that are part of the current list (do not call directly instead call GetProductsForWorklist)</summary>
        private WProduct products;
        #endregion

        #region Properties
        /// <summary>Ward stock list ID currently loaded (-1 if non loaded)</summary>
        public int WardProductListID { get { return this.WardStockList.Any() ? this.WardStockList[0].WWardProductListID : -1; } }

        /// <summary>
        /// The WWardProductListLineID for the currently selected line in the editor
        /// In muli selection this is the last line selected
        /// </summary>
        public int SelectedLineID { get; set; }

        /// <summary>The WWardProductListLineID of all lines selected in the editor</summary>
        public int[] MultiSelectLineIDs { get; set; }

        /// <summary>If user can edit the list (edibable mode and list is locked by user)</summary>
        public bool CanEdit { get; set; }

        /// <summary>If user can use the (issue\return against the list) no other user have the list (hard) locked</summary>
        public bool CanUse { get; set; }

        /// <summary>mode for the editor (e.g. view only, editable) comes from desktop parameter</summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public WardStockListMode  Mode { get; set; }

        /// <summary>If to display money values in editor</summary>
        public MoneyDisplayType MoneyDisplayType  { get; set; }

        /// <summary>If desktop parameter allows selection of list by terminal</summary>
        public bool SelectListByTerminal;

        /// <summary>Current terminal for user (comes from session ID) needs here as used by Javascript</summary>
        public int TerminalID { get; set; }

        /// <summary>total cost of list (ex vat) needed as used by javascript</summary>
        public decimal TotalCostExVat { get; set; }

        /// <summary>total vat value of list needed as used by javascript</summary>
        public decimal TotalVat { get; set; }

        /// <summary>Needs to be property so JSON will parse as used on client</summary>
        public string  TotalCostFormatted 
        { 
            get
            {
                decimal totalIncVat = Math.Round(this.TotalCostExVat, 0, MidpointRounding.AwayFromZero) + Math.Round(this.TotalVat, 0, MidpointRounding.AwayFromZero);
                return string.Format("{0} + {1} {2} = {3}", 
                                            this.TotalCostExVat.ToMoneyString(this.MoneyDisplayType), 
                                            this.TotalVat.ToMoneyString(this.MoneyDisplayType),
                                            PharmacyCultureInfo.SalesTaxName,
                                            totalIncVat.ToMoneyString(this.MoneyDisplayType));
            }
        }

        /// <summary>Used wehn sending complex data clinet side</summary>
        public object returnData { get; set; }

        /// <summary>Ward stock list data (saved and loaded from DB session cache)</summary>
        [JsonIgnore]
        public WWardProductList WardStockList { get; private set; }

        /// <summary>Ward stock list lines data (saved and loaded from DB session cache)</summary>
        [JsonIgnore]
        public WWardProductListLine WardStockListLines { get; private set; }
        #endregion

        public WardStockListController()
        {
            this.SelectedLineID     = -1;
            this.MultiSelectLineIDs = new int[0];
            this.CanEdit            = false;
            this.CanUse             = false;
            this.Mode               = WardStockListMode.ViewOnly;
            this.MoneyDisplayType   = MoneyDisplayType.Show;
            this.WardStockList      = new WWardProductList();
            this.WardStockListLines = new WWardProductListLine();
            this.products           = null;
            this.TotalCostExVat     = 0;
            this.TotalVat           = 0;
        }

        /// <summary>Used to create a new list</summary>
        /// <param name="newListProperties">New list properties</param>
        public void NewList(WWardProductListRow newListProperties)
        {
            this.WardStockList.RowLockingOption = LockingOption.HardLock;
            this.WardStockList.PreventUnlockOnDispose = true;
            this.WardStockList.Clear();
            this.WardStockListLines.Clear();
            this.products  = new WProduct();
            this.TotalCostExVat = 0;
            this.TotalVat       = 0;

            this.WardStockList.Add().CopyFrom(newListProperties);

            this.CanEdit = true;
            this.CanUse  = true;

            this.MultiSelectLineIDs = new int[0];
            this.SelectedLineID     = -1;
        }

        /// <summary>
        /// Open up a ward stock list
        /// Will soft lock the list (but will not throw soft lock exception)
        /// Will throw hard lock exception if another user has (hard) locked list (but all list data will be loaeded just can use or edit list)
        /// </summary>
        /// <param name="wwardProductListID">ID of the list to open</param>
        public void OpenList(int wwardProductListID)
        {
            // Put list in soft lock mode
            this.WardStockList.RowLockingOption = LockingOption.SoftLock;   
            this.WardStockList.PreventUnlockOnDispose = true;
            try
            {
                this.WardStockList.LoadByID(wwardProductListID);
            }
            catch (SoftLockException) { }   // currently no reason to notify on softlock only need to prevent hard locking

            // Load the lines
            this.WardStockListLines.LoadByWWardProductListID(SessionInfo.SiteID, wwardProductListID);

            // Load the product used by the list
            this.products = new WProduct();
            this.products.LoadBySiteAndWWardProductListID(SessionInfo.SiteID, wwardProductListID);

            // Recalc totals
            this.ReCalcualteCost();

            // Check is list is hard locked
            int sessionLock = WardStockList[0].SessionLock;
            bool isHardLocked = (sessionLock != 0 && (sessionLock != SessionInfo.SessionID) && Database.ExecuteSQLScalar<int?>("Exec pSessionExistsPharmacy " + sessionLock.ToString()) != null);

            this.CanEdit= false;
            this.CanUse = !isHardLocked;

            this.SelectFirstLine();

            // If hard lock the throw error
            if (isHardLocked)
            {
                this.WardStockList.UnlockRows();    // removes the hard lock (better user experience) 108353 21Jan15 XN
                throw new HardLockException(WardStockList.TableName, WardStockList.GetPKColumnName(), WardStockList[0].WWardProductListID, WardStockList[0].SessionLock);
            }
        }

        /// <summary>Save list to db</summary>
        public void Save()
        {
            // Get list of lines as IDs may update afer save
            IEnumerable<WWardProductListLineRow> multiSelectLines = this.WardStockListLines.FindByIDs(this.MultiSelectLineIDs).ToList();
            WWardProductListLineRow              selectedLine     = this.WardStockListLines.FindByID (this.SelectedLineID    );

            // First check if adding if the list code is already in use
            WWardProductListRow list = this.WardStockList.First();
            if ( list.RawRow.RowState == DataRowState.Added && WWardProductList.GetBySiteCodeAndInUse(list.SiteID, list.Code, null) != null )
                throw new ApplicationException("Failed to save.\nCode already in use.");

            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                // Save list
                this.WardStockList.Save();

                // Update lines added lines to have the new WWardProductListID
                int wwardProductListID = this.WardStockList[0].WWardProductListID;
                foreach (var row in this.WardStockListLines)
                {
                    if (row.RawRow.RowState == DataRowState.Added)
                        row.WWardProductListID = wwardProductListID;
                }

                // Save lines
                this.WardStockListLines.Save(this.WardStockList);

                trans.Commit();
            }

            // Update the selected line IDs as may of changed
            this.MultiSelectLineIDs = multiSelectLines.Select(l => l.WWardProductListLineID).ToArray();
            if (selectedLine != null)
                this.SelectedLineID  = selectedLine.WWardProductListLineID;
        }

        /// <summary>Save list as new list and then opens that list in edit mode</summary>
        /// <param name="newRow">New list properties</param>
        public void SaveAs(WWardProductListRow newRow)
        {
            WWardProductListLine newLines = new WWardProductListLine();

            // Might be empty if no rows added to the list
            if (this.WardStockListLines.Table != null)
            {
                // Get list of columns (for list line objects)
                var columns = this.WardStockListLines.Table.Columns.OfType<DataColumn>().Select(c => c.ColumnName).ToList();
                columns.Remove(this.WardStockListLines.GetPKColumnName());
                columns.Remove("WardStockListID");

                // Copy all lines (except PK  and stock list ID)
                foreach (var originalRow in this.WardStockListLines) newLines.Add().CopyFrom(originalRow, columns);
            }

            // Create new list
            this.NewList(newRow);

            // set new list lines
            this.WardStockListLines = newLines;

            // Save new list
            this.Save();

            this.CanEdit = true;
            this.CanUse  = true;
            this.SelectFirstLine();
        }

        /// <summary>
        /// Add lines from DataSet XML to the list
        /// either above of below current line
        /// </summary>
        /// <param name="WWardProductListLinesXML">DataSet XML</param>
        /// <param name="mode">If lines are to be added above or below current line (update to add if can't find current line)</param>
        /// <param name="productsForLine">New list of products for all the newly added lines</param>
        public void AddLines(string WWardProductListLinesXML, ref string mode, out WProduct productsForLine)
        {
            // Set the ward list as might be different to list it came from
            WWardProductListLine tempLines = new WWardProductListLine();
            tempLines.ReadXml(WWardProductListLinesXML);

            var newNSVCodes = tempLines.FindDrugLines().Select(l => l.NSVCode).Distinct();

            productsForLine = new WProduct();
            productsForLine.LoadByProductAndSiteID(newNSVCodes, SessionInfo.SiteID);

            this.AddLines(tempLines, productsForLine, ref mode);
        }

        /// <summary>
        /// Adds the lines to the list (will copy the line data)
        /// either above of below current line
        /// </summary>
        /// <param name="lines">Lines to add to the list</param>
        /// <param name="products">Products for the currently selected lines</param>
        /// <param name="mode">If lines are to be added above or below current line (update to add if can't find current line)</param>
        public void AddLines(IEnumerable<WWardProductListLineRow> lines, IEnumerable<WProductRow> products, ref string mode)
        {
            // get ordered list (before insertion)
            var orderList = this.WardStockListLines.OrderByScreenPos().ToList();

            int wardProductListID = this.WardProductListID;

            // Get list of columns (for list line objects)
            var columns = lines.First().RawRow.Table.Columns.OfType<DataColumn>().Select(c => c.ColumnName).ToList();   // Use lines as this.WardStockListLines might not contain any rows yet
            columns.Remove( this.WardStockListLines.GetPKColumnName() );
            columns.Remove( "WardStockListID" );

            // Copy the lines setting new wardProductListID 
            foreach(var l in lines)
            {
                var newRow = this.WardStockListLines.Add();
                newRow.CopyFrom(l, columns);
                newRow.WWardProductListID = wardProductListID;
            }

            // Get index point of insert
            int insertIndex = orderList.IndexOf(this.SelectedLineID);
            var newLines    = this.WardStockListLines.Skip(orderList.Count);
            if (insertIndex == -1)
            {
                orderList.AddRange( newLines );
                mode = "add";
            }
            else if (mode.EqualsNoCaseTrimEnd("above"))
                orderList.InsertRange( insertIndex, newLines );
            else
                orderList.InsertRange( insertIndex + 1, newLines );

            // Update the order
            orderList.ResetScreenPositions();

            // Update cost
            this.UpdateTotalCost(lines, products, 1);

            // reselect lines
            this.SelectedLineID     = newLines.First().WWardProductListLineID;
            this.MultiSelectLineIDs = newLines.Select(c => c.WWardProductListLineID).ToArray();
        }

        /// <summary>Updates the line in the list (and the total cost) line data will be coppied over existnig</summary>
        /// <param name="newLine">line info</param>
        /// <param name="product">Product for the line</param>
        public void UpdateLine(WWardProductListLineRow line, WProductRow product)
        {
            // Get original line
            var originalLine = this.WardStockListLines.FindByID( line.WWardProductListLineID );

            // Remove lines existing cots
            this.UpdateTotalCost(new [] { originalLine }, new [] { product }, -1);

            // Copy line
            originalLine.CopyFrom(line);

            // Update line cost
            this.UpdateTotalCost(new [] { line }, new [] { product },  1);
        }

        /// <summary>Delete lines from the list (will also update the total cost of list)</summary>
        /// <param name="linesToDelete">lines to delete</param>
        /// <param name="products">Products for the lines</param>
        public void DeleteLines(IEnumerable<WWardProductListLineRow> linesToDelete, IEnumerable<WProductRow> products)
        {
            int selectedRowIndex = this.WardStockListLines.OrderByScreenPos().IndexOf( this.SelectedLineID );

            // Remove lines existing cots
            this.UpdateTotalCost(linesToDelete, products, -1);

            // Remove lines
            this.WardStockListLines.RemoveAll( linesToDelete );

            // Selecte the next avaiable line
            var selectedRow = this.WardStockListLines.OrderByScreenPos().ElementAtOrDefault(selectedRowIndex);
            if (selectedRow == null)
                selectedRow = this.WardStockListLines.LastOrDefault();
            if (selectedRow != null)
            {
                this.SelectedLineID     = selectedRow.WWardProductListLineID;
                this.MultiSelectLineIDs = new int[] { selectedRow.WWardProductListLineID };
            }
        }

        /// <summary>Delete the list (will also delete from DB)</summary>
        public void DeleteList()
        {
            // Can't delete if not in edit mode
            if (!this.CanEdit || this.Mode != WardStockListMode.Editable)
                throw new ApplicationException ("Can't delete as not allowed to edit list.");
            
            // delete liust and lines
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {                                
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add("@WWardProductListID", this.WardStockList.First().WWardProductListID);
                Database.ExecuteSPNonQuery("pWardStockListLinesDeleteByWWardProductListID", parameters);    // Delete all lines (include logically deleted ones)
                this.WardStockList.RemoveAll();
                this.WardStockList.Save();
                trans.Commit();
            }
            
            // Clear the object
            this.Clear();
            this.SelectedLineID     = -1;
            this.MultiSelectLineIDs = new int[0];
            this.CanEdit            = false;
            this.CanUse             = false;
            this.TotalCostExVat     = 0;
            this.TotalVat           = 0;
        }

        /// <summary>
        /// Hard locks list
        /// Application exception if in ViewOnly mode
        /// Does nothing but sent CanEdit mode in TemporaryEdit mode
        /// In Editable mode will put list in hard lock mode
        ///     Soft lock exception - if someone has list open
        ///     Hard lock exception - if another user has list locked
        /// </summary>
        public void Lock()
        {
            if ( this.Mode == WardStockListMode.ViewOnly )
                throw new ApplicationException ("Desktop Mode parameters prevents locking of list.");

            if ( this.Mode == WardStockListMode.Editable )  // Only perform hard lock in Editable mode, do nothing in temp edit mode
            {
                // re-apply the soft lock (so will error if anyone else has a soft lock)
                SoftLockResults softLockResults = new SoftLockResults("WWardProductList");
                softLockResults.LockRows(this.WardStockList.Table);

                // Re-load the data
                int wwardProductListID = this.WardStockList[0].WWardProductListID;
                this.WardStockList.RowLockingOption = LockingOption.HardLock;
                this.WardStockList.PreventUnlockOnDispose = true;
                this.WardStockList.LoadByID(wwardProductListID);
                this.WardStockListLines.LoadByWWardProductListID(SessionInfo.SiteID, wwardProductListID);

                // Remove the soft lock
                softLockResults.UnlockRows();
            }

            this.CanEdit = true;
            this.CanUse  = true;
        }

        /// <summary>Removed hard lock from list</summary>
        public void Unlock()
        {
            if (this.WardStockList.RowLockingOption == LockingOption.HardLock)
                this.WardStockList.UnlockRows();
        }

        /// <summary>Clear all list lines and data</summary>
        public void Clear()
        {
            this.WardStockListLines.Clear();
            this.WardStockList.Clear();
            this.TotalCostExVat = 0;
            this.TotalVat       = 0;
            this.products       = null;
            PharmacyDataCache.SaveToDBSession("WardStockListPageInfo", null);
        }

        /// <summary>
        /// Return null if can soft lock (so no other users look at list), or soft lock exception details if user is look at list
        /// Will not check if anyone has hard locked the list
        /// </summary>
        public SoftLockException IfListOpenByOthers()
        {
            return this.WardProductListID == -1 ? null : new SoftLockResults(this.WardStockList.TableName).IsLockedByOtherUser(this.WardProductListID);
        }

        /// <summary>Get all product for all lines in the list (either uses cache data or reads from DB)</summary>
        public WProduct GetProductsForWorklist()
        {
            // If not loaded yet then load
            if (this.products == null)
            {
                products = new WProduct();
                if (this.WardProductListID != -1)
                    products.LoadBySiteAndWWardProductListID(SessionInfo.SiteID, this.WardProductListID);
            }

            // Check all drugs have been loaded
            var requiredNSVCodes = ( this.WardStockListLines.FindDrugLines().Select(l => l.NSVCode) ).Distinct().ToList();
            foreach(var p in products)
                requiredNSVCodes.Remove( p.NSVCode );

            // Load any missing durgs
            if (requiredNSVCodes.Any())
                products.LoadByProductAndSiteID(requiredNSVCodes, SessionInfo.SiteID, true);

            // return the list
            return products;
        }

        /// <summary>Gets selected line (when multiple lines selected will be the last selected line)</summary>
        public WWardProductListLineRow GetSelectedLine()
        {
            return this.WardStockListLines.FindByID( this.SelectedLineID );
        }

        /// <summary>Returns all selected lines</summary>
        public IEnumerable<WWardProductListLineRow> GetMultiSelectLines()
        {
            return this.WardStockListLines.FindByIDs( this.MultiSelectLineIDs );
        }

        /// <summary>Load list and line data from DB data cache</summary>
        public void LoadFromCache()
        {
            XmlReaderSettings readerSettings = new XmlReaderSettings();
            readerSettings.ConformanceLevel = ConformanceLevel.Fragment;

            // Get data from cache
            string dataStr = PharmacyDataCache.GetFromDBSession("WardStockListPageInfo");

            // data is compressed so decompress and load
            using (MemoryStream memStream = new MemoryStream(Convert.FromBase64String(dataStr)))
            {
                using(DeflateStream comp = new DeflateStream(memStream, CompressionMode.Decompress))
                {
                    memStream.Position = 0;
                    using (XmlReader reader = XmlReader.Create(comp, readerSettings))
                    {
                        reader.Read();  // Read to first node
                        this.WardStockList.ReadXml        (reader);
                        this.WardStockListLines.ReadXml   (reader);
                    }
                }
            }
        }

        /// <summary>Save list and line data to DB session cache</summary>
        /// <returns>Returns this control as a JSON string (without the data saved to the DB session cache)</returns>
        public string SaveToCache()
        {
            XmlWriterSettings writerSettings = new XmlWriterSettings();
            writerSettings.Indent             = false;
            writerSettings.OmitXmlDeclaration = true;
            writerSettings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Save data as compressed DatasSet XML 
            using (MemoryStream memStream = new MemoryStream())
            {
                using(DeflateStream comp = new DeflateStream(memStream, CompressionMode.Compress, true))
                {
                    using(XmlWriter writer = XmlWriter.Create(comp, writerSettings))
                    {
                        this.WardStockList.WriteXml      (writer);
                        this.WardStockListLines.WriteXml (writer);

                        writer.Flush();
                        writer.Close();
                    }

                    comp.Flush();
                    comp.Close();
                }

                // Save
                PharmacyDataCache.SaveToDBSession("WardStockListPageInfo", Convert.ToBase64String(memStream.GetBuffer(), 0, (int)memStream.Length));
            }

            // Returns control as JSON string
            return JsonConvert.SerializeObject(this);
        }

        /// <summary>Creates control from JSON string, and loads data from DB Session cache</summary>
        public static WardStockListController Create(string jsonData)
        {
            WardStockListController result = JsonConvert.DeserializeObject<WardStockListController>(jsonData);
            result.LoadFromCache();
            return result;
        }

        /// <summary>Returns true if multiple selected lines are in a contiguous block</summary>
        public bool IsSelectedLinesContiguous()
        {
            //var orderLines    = this.WardStockListLines.OrderByScreenPos().ToList();  27Jul15 XN filter out lines that do not have valid NSVCodes (as will not be displayed in list)
            var validNSVCodes = new HashSet<string>(this.GetProductsForWorklist().Select(p => p.NSVCode).Distinct());
            var orderLines    = this.WardStockListLines.Where(l => l.LineType == WWardProductListLineType.Title || validNSVCodes.Contains(l.NSVCode)).OrderByScreenPos().ToList();
            int count         = this.MultiSelectLineIDs.Count();
            int firstIndex = -1, lastIndex = -1;

            // Get first and last index in selection
            for (int index = 0; index < orderLines.Count; index++)
            {
                if ( this.MultiSelectLineIDs.Contains(orderLines[index].WWardProductListLineID) )
                {
                    lastIndex = index;
                    if (firstIndex == -1)
                        firstIndex = index;
                }
            }

            return (count == lastIndex - firstIndex + 1);
        }

        /// <summary>Recaculate Cost ex vat and ttotal cost for all items in the list</summary>
        public void ReCalcualteCost()
        {
            this.TotalCostExVat = 0;
            this.TotalVat       = 0;
            UpdateTotalCost(this.WardStockListLines, this.GetProductsForWorklist(), 1);
        }

        /// <summary>Update the total cost of the list</summary>
        /// <param name="lines">Lines to update cost for</param>
        /// <param name="products">List of products to update cost for</param>
        /// <param name="multiplier">-1 to remove line cost from total, 1 to add line cost to total</param>
        private void UpdateTotalCost(IEnumerable<WWardProductListLineRow> lines,  IEnumerable<WProductRow> products, int multiplier)
        {
            foreach (var l in lines)
            {
                WProductRow drug = null;
                if (l.LineType == WWardProductListLineType.Drug)
                    drug = products.FindBySiteIDAndNSVCode(SessionInfo.SiteID, l.NSVCode);
                if (drug != null)
                {
                    decimal costExVat = (multiplier * l.TopupLvl * drug.AverageCostExVatPerPack);
                    TotalCostExVat += costExVat;
                    TotalVat       += costExVat * ((drug.VATRate ?? 1) - 1);
                }
            }
        }

        /// <summary>Select first line in list</summary>
        private void SelectFirstLine()
        {
            WWardProductListLineRow line = this.WardStockListLines.OrderBy(l => l.DisplayIndex).FirstOrDefault();
            this.SelectedLineID     = (line == null) ? -1         : line.WWardProductListLineID;
            this.MultiSelectLineIDs = (line == null) ? new int[0] : new []{ line.WWardProductListLineID }; 
        }
    }
}
