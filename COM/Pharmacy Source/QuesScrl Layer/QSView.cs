//===========================================================================
//
//							    QSView.cs
//
//  Provides functions and methods for loading and handling all the QuesScrl
//  data items for a view
//
//  Data is read from WConfiguration one row continaing the data indexes
//  that make up the view, and a row for each data item.
//  See for more details QuesScrl.ascx.cs
//  
//  Usage
//  To load the stock maintance view 3 creating two controls for each 
//  data item one for site 15, other for site 19.
//  QSView view = new QSView
//  view.Load("D|STKMAINT", "Views", "Data", 3, new [] { 19, 15 })
//
//  get web control value for data index 8, site 19
//  view.GetValueByDataIndexAndSiteID(8, 19)
//
//	Modification History:
//	23Jan14 XN  Written
//  16Jun14 XN  Got Load to use shared version of WConfiguration to remove
//              dependancy on pharmacy data layer 88509
//  25Jun14 XN  fixed issue in Load when removing duplicate index
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Provides helper functions to load in information for a QuesScrl view to create a list of data input items</summary>
    public class QSView : List<QSDataInputItem>
    {
        /// <summary>View descritpion</summary>
        public string ViewDescription { get; private set; }

        /// <summary>
        /// Loads QSDataInputItems from the db for a particular view index (uses SessionInfo.SiteID for the site)
        /// Reads both view and data information from WConfiguration
        /// </summary>
        /// <param name="category">WConfiguration.Category to load from (e.g. D|STKMAINT)</param>
        /// <param name="sectionView">WConfiguration.Section for the view (e.g. Views)</param>
        /// <param name="sectionData">WConfiguration.Section for the data (e.g. Data)</param>
        /// <param name="keyViewIndex">WConfiguration.Key for the view (e.g. 1)</param>
        /// <param name="siteIDs">List of site ids to create all the web controls for</param>
        public void Load(string category, string sectionView, string sectionData, int keyViewIndex, IEnumerable<int> siteIDs)
        {
            // Load view data (csv list of view indexes
            string[] view = WConfigurationController.LoadAndCache<string>(SessionInfo.SiteID, category, sectionView, keyViewIndex.ToString(), string.Empty, false).Trim().Split(',');

            // Load all the config data sections
            IDictionary<string,string> config = WConfigurationController.LoadByCategoryAndSection(SessionInfo.SiteID, category, sectionData, false);

            // Get qs view description
            this.ViewDescription = view.Any() ? view[0] : string.Empty;

            // For each item in the view
            // skip first item as view description
            for(int v = 1; v < view.Length; v++)
            {
                try
                {
                    QSDataInputItem control = new QSDataInputItem();
                    
                    // Get and split the config data
                    int index = Math.Abs(int.Parse(view[v].Trim()));
                    string indexStr = index.ToString();
                    
                    string[] data = config[indexStr].Split(','); // Remove quotes and split

                    // Read config data
                    control.index       = index;
                    control.maxLength   = int.Parse(data[1].Trim());
                    control.description = data.Length > 3 ? data[3] : string.Empty;
                    control.infoText    = data.Length > 4 ? data[4] : string.Empty;

                    string toolTip = data.Length > 7 ? data[7] : string.Empty;

                    bool lookupOnly = false;    // If control can only be set by a lookup
                    if (data.Length > 8)
                        BoolExtensions.TryPharmacyParse(data[8], out lookupOnly);

                    // 102125 XN 15Oct14 Determine if item should be froced to mandatory (If false this does NOT necessarily mean that field is optional as might be hardcoded as mandatory)
                    bool forceMandatory = false;
                    if (data.Length > 9)
                        BoolExtensions.TryPharmacyParse(data[9], out forceMandatory);
                    control.ForceMandatory = forceMandatory;

                    bool enabled = view[v].TrimStart().StartsWith("-");

                    // Get web control type
                    QuesScrlCtrlType ctrlType;
                    bool upperCase = false;
                    int ctrlTypeIndex = int.Parse(data[2].Trim());
                    if (index == 0)
                        ctrlType = QuesScrlCtrlType.None;
                    else if (ctrlTypeIndex == -1)
                    {
                        ctrlType = QuesScrlCtrlType.TextBox;
                        upperCase= true;
                    }
                    else if (Enum.IsDefined(typeof(QuesScrlCtrlType), ctrlTypeIndex))
                    {
                        ctrlType  = (QuesScrlCtrlType)ctrlTypeIndex;
                        upperCase = (ctrlType == QuesScrlCtrlType.TextBox_YN);
                    }
                    else
                    {
                        ctrlType = QuesScrlCtrlType.TextBox;
                        enabled = true;
                        control.infoText += " (invalid control type " + ctrlTypeIndex.ToString() + ")";
                    }

                    // If index was -1 then set control as spacer
                    control.isSpacer = ctrlType == QuesScrlCtrlType.None;

                    // Get default data, custom mask, or button text
                    string defaultValue = string.Empty, customMask = string.Empty;
                    if (data.Length > 5)
                    {
                        switch(ctrlType)
                        {
                        case QuesScrlCtrlType.None:                     break;
                        case QuesScrlCtrlType.TextBox_PatterMask:       customMask = data[5]; 
                                                                        upperCase  = (customMask == customMask.ToUpper()); 
                                                                        break;
                        case QuesScrlCtrlType.Button:                   defaultValue= data[5]; break;
                        case QuesScrlCtrlType.TextBox_SingleCharCode:   customMask  = data[5]; 
                                                                        upperCase  = (customMask == customMask.ToUpper()); 
                                                                        break;
                        default:                                    
                            defaultValue= data[5];             
                            if (data.Length > 6)
                                customMask = data[6];
                            break;
                        }
                    }

                    // Adds all the controls to the list
                    foreach (int siteID in siteIDs)
                        control.AddControl(ctrlType, index, siteID, defaultValue, control.maxLength, upperCase, customMask, enabled, lookupOnly, toolTip);

                    this.Add(control);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(string.Format("QuesScrlParser.Load (category:{0} sectionView:{1} sectionData{2} data index:{3} - Errored {4}", category, sectionView, sectionData, v, ex.Message));
                }
            }

            //// Remove duplicate indexes (ignore 0 items) 25Jun14 XN 88506 fix load issue
            //int c = this.Count - 1;
            //HashSet<int> uniqueIndexes = new HashSet<int>();
            //while (c >= 0)
            //{
            //    if (uniqueIndexes.Contains(this[c].index))
            //        this.RemoveAt(c);
            //    else
            //    {
            //        if (this[c].index != 0)
            //            uniqueIndexes.Add(this[c].index);
            //        c--;
            //    }
            //}

            // Remove duplicate indexes (ignore 0 items)
            int c = 0;
            HashSet<int> uniqueIndexes = new HashSet<int>();
            while (c < this.Count)
            {
                if (uniqueIndexes.Contains(this[c].index))
                    this.RemoveAt(c);
                else
                {
                    if (this[c].index != 0)
                        uniqueIndexes.Add(this[c].index);
                    c++;
                }
            }
        }

        /// <summary>If the view contains the data index</summary>
        public bool ContainsDataIndex(int index)
        {
            return this.Any(i => i.index == index);
        }

        /// <summary>Returns the first control with the data index (or null)</summary>
        public QSDataInputItem FindByDataIndex(int index)
        {
            return this.FirstOrDefault(i => i.index == index);
        }

        /// <summary>Returns the value from the web control for the data index, and site ID</summary>
        public string GetValueByDataIndexAndSiteID(int index, int siteID)
        {
            return this.FirstOrDefault(i => i.index == index).GetValueBySiteID(siteID);
        }

        /// <summary>Returns the value from the web control for the data index, and site ID (or null if can't convert)</summary>
        public T? GetValueByDataIndexAndSiteID<T>(int index, int siteID) where T : struct
        {
            try
            {
                return ConvertExtensions.ChangeType<T>(GetValueByDataIndexAndSiteID(index, siteID));
            }
            catch (Exception )
            {
                return null;
            }
        }

        /// <summary>Returns if the value from the web control is null or empty (or if data index does not exist for the view)</summary>
        public bool ValueIsNullOrEmpty(int index, int siteID)
        {
            QSDataInputItem quesScrlInfo = this.FirstOrDefault(i => i.index == index);
            if (quesScrlInfo == null)
                return true;
            return string.IsNullOrEmpty(quesScrlInfo.GetValueBySiteID(siteID));
        }    
    }
}
