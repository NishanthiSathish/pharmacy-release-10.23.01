//===========================================================================
//
//                  WWardProductListLineAccessor.cs
//
//  Accessor class for WWardProductListLineRow
//
//  Supports interface IQSDisplayAccessor, and the QSBaseProcessor
//  
//	Modification History:
//  08Sep14 XN  Written 98658
//  08Dec14 XN  106047 if description, and packsize, does not match product then error
//  17Dec14 XN  38034 Added support for QSBaseProcessor (for search and update)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using System.Xml;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.wardstocklistlayer
{
    public class WWardProductListLineAccessor : QSBaseProcessor, IQSDisplayAccessor
    {
        #region Data Indexes
        private const int DATAINDEX_DESCRIPTION = 1;
        private const int DATAINDEX_PACKSIZE    = 2;
        private const int DATAINDEX_QUANTITY    = 3;
        private const int DATAINDEX_PRINTLABEL  = 4;
        private const int DATAINDEX_COMMENTS    = 5;
        private const int DATAINDEX_DISPLAYINDEX= 6;
        #endregion

        #region Display accessor members
        /// <summary>Display option for the money</summary>
        private MoneyDisplayType moneyDisplayType;

        /// <summary>List of product that are present for each line in the list</summary>
        private IEnumerable<WProductRow> productInList;

        /// <summary>If DLO is allowed</summary>
        private bool allowDLO;

        /// <summary>Associated list</summary>
        private WWardProductListRow list;
        #endregion

        #region Public Properties
        public WWardProductListLine Lines { get; private set; }
        #endregion

        #region Constructor
        public WWardProductListLineAccessor() : base(null) { }

        /// <summary>Constuctor for the QSBaseProcessor</summary>
        /// <param name="lines">Lines to display in QuesScrol</param>
        public WWardProductListLineAccessor(WWardProductListLine lines) : base(lines.Select(l => l.WWardProductListLineID)) 
        { 
            this.Lines = lines;
        }

        /// <summary>Constuctor for the IQSDisplayAccessor interface</summary>
        /// <param name="productInList">List of product referenced by the stock list lines</param>
        /// <param name="moneyDisplayType">If financial values are to be displayed</param>
        /// <param name="printPickingTicket">If the ward stock list has print picking ticket enabled</param>
        public WWardProductListLineAccessor( WWardProductListRow list, IEnumerable<WProductRow> productInList, MoneyDisplayType moneyDisplayType, bool printPickingTicket ) : base(null)
        {
            this.productInList    = productInList;
            this.moneyDisplayType = moneyDisplayType;
            this.allowDLO         = printPickingTicket && Settings.AllowDLO;
            this.list             = list;
        }
        #endregion

        #region IQSDisplayAccessor Members
        /// <summary>the main supported BaseRow type for the accessor (will be WWardProductListLineRow)</summary>
        public Type SupportedType { get { return typeof(WWardProductListLineRow); } }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        public string AccessorTag { get { return "Stock List Line"; } }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of type (WWardProductListLineRow)</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        public string GetValueForDisplay(BaseRow r, int dataIndex, QSDataType dataType, string propertyName, string formatOption)
        {
            WWardProductListLineRow row = (r as WWardProductListLineRow);

            switch (propertyName.ToLower())
            {
            case "description": // 108628 16Jan14 XN Updates to displa
                {                
                bool isItalics          = formatOption.ToLower().Contains("highlight_no_match") && !row.ToString().EqualsNoCaseTrimEnd(row.Description_SiteProductData);    // 106047 XN 8Dec14 make italics if description is different
                bool isShrinkLongText   = formatOption.ToLower().Contains("shrink_long_text");                                      // 108628 XN 16Jan14 layout improvements
                bool isGreen            = formatOption.ToLower().Contains("highlight_requisition") && row.OrdDateTime_WRequis.HasValue;     // 108628 XN 16Jan14 layout improvements
                StringBuilder style     = new StringBuilder();
                string description      = row.ToString();
                
/*                if (isShrinkLongText)
                {
                    if ( description.Length > 45 )
                        style.Append("font-size:7pt;");
                    else if ( description.Length > 38 )
                        style.Append("font-size:8pt;");
                }*/

                if (isItalics)
                    style.Append("font-style:italic;");  

                if (isGreen)
                    style.Append("font-weight:bold;color:green;");

                if (style.Length > 0)
                    return string.Format("<span style='{0}'>{1}</style>", style, description.XMLEscape());
                else 
                    return description.XMLEscape();
                }
            case "printlabel" : 
                if (formatOption.ToLower() == "standard")
                {
                    switch (row.PrintLabel)
                    {
                    case shared.PrintLabelType.NoLabel:     return string.Empty;
                    case shared.PrintLabelType.PrintLabel:  return "Print";
                    case shared.PrintLabelType.BatchBulk:   return "Batch";     // Probably not needed 
                    case shared.PrintLabelType.DLO:         return allowDLO ? "DLO" : string.Empty;
                    }
                }
                break;
            case "conversionfactorpacktoissueunits":
                {
                bool isWithIssueUnits = formatOption.ToLower().Contains("issue units");
                bool isItalics        = formatOption.ToLower().Contains("highlight no match") && row.ConversionFactorPackToIssueUnits != row.ConversionFactorPackToIssueUnits_SiteProductData;  // 106047 XN 8Dec14 make italics if packsize is different
                StringBuilder str = new StringBuilder();

                if (isItalics)
                    str.Append("<i>");

                if (isWithIssueUnits)
                    str.AppendFormat("{0} {1}", row.GetConversionFactorPackToIssueUnits(), row.IssueUnits_SiteProductData.XMLEscape());
                else
                    str.Append(row.GetConversionFactorPackToIssueUnits().ToString());

                if (isItalics)
                    str.Append("</i>");

                return str.ToString();
                }

            case "{requisition}":       // 108628 20Jan15 XN Updates to display
                {
                if (formatOption.ToLower().Contains("for_grid") && list.WCustomerID.HasValue)
                {
                    // Either TF (to follow) red bold or RQ (Requisition) green bold
                    if (row.HasToFollow)
                    {
                        return "<span style='color:red;font-weight:bold;' title='To Follow'>TF</span>";
                    }
                    else if (row.QtyOrdered_WRequis.HasValue)
                    {
                        return "<span style='color:green;font-weight:bold;' title='Requisitions'>RQ</span>";                            
                    }
                }
                else if (formatOption.ToLower().Contains("for_panel_requisition") && row.OrdDateTime_WRequis.HasValue && list.WCustomerID.HasValue)
                {
                    // Display {qty ordered} on {Order/picking ticket date} Ref: {Requsition number} in green italics
                    StringBuilder str = new StringBuilder("<span style='color:green;font-style:italic;'>");
                    if (row.QtyOrdered_WRequis != null)
                    {
                        str.Append(row.QtyOrdered_WRequis.ToString("0.###"));
                    }
                    
                    if (row.QtyOrdered_WRequis != null && row.OrdDateTime_WRequis != null)
                    {
                        str.Append(" on ");
                    }

                    if (row.OrdDateTime_WRequis != null)
                    {
                        str.Append(row.OrdDateTime_WRequis.ToPharmacyDateTimeString());
                    }

                    if (!string.IsNullOrWhiteSpace(row.RequisitionNum_WRequis))
                    {
                        str.Append(" Ref:" + row.RequisitionNum_WRequis);
                    }

                    str.Append("</span>");                    
                    return str.ToString();
                }
                }
                
                break;

            case "HasToFollow":    // 108628 16Jan15 XN Updates to display
                {
                string str = string.Empty;

                // If ToFollow item show in red italics
                if (row.HasToFollow)
                {
                    if (formatOption.EqualsNoCase("Coloured_Grid"))
                    {
                        str = "<span style='color:red;font-weight:bold;' title='To Follow'>Yes</span>";
                    }
                    else if (formatOption.EqualsNoCase("Coloured_Panel"))
                    {
                        str = "<span style='color:red;font-style:italic;' title='To Follow'>Yes</span>";
                    }
                    else
                    {
                        str = "Yes";
                    }
                }

                return str;
                }

            case "lastissue":
            case "dailyissue":  // 108628 16Jan14 XN Updates to displa
                {
                string str = row.LastIssueDate == null ? string.Empty : QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);

                if (row.IsIssueAdHoc && !string.IsNullOrWhiteSpace(str))
                {
                    // If addhoc Issue show organge background colour
                    if (formatOption.ToLower().Contains("highlight_adhoc_grid"))
                    {
                        str = string.Format("<span style='color:red;font-weight:bold;' title='Ad-Hoc issue'>AH {0}</span>", str);
                    }
                    else if (formatOption.ToLower().Contains("text_adhoc_panel"))
                    {
                        str = string.Format("<span style='color:red;font-style:italic;' title='Ad-Hoc issue'>{0} (Ad-Hoc)</span>", str);
                    }
                }

                return str;
                }

            case "lastissuedate":   // 108628 16Jan14 XN Updates to displa
                {                
                string str = string.Empty;
                    
                if (row.LastIssueDate != null)
                {
                    string style    = string.Empty;
                    string tooltip  = string.Empty;

                    str = formatOption.Contains("dateOnly") ? row.LastIssueDate.ToPharmacyDateString() : row.LastIssueDate.ToPharmacyDateTimeString();

                    // If today's date show in red bold
                    if (formatOption.Contains("Now & Yesturday Colours"))
                    {
                        if (row.LastIssueDate.Value.Date == DateTime.Now.Date)
                        {
                            str = string.Format("<span style='color:red;font-weight:bold;'>{0}</span>", str);
                        }
                        else if (row.LastIssueDate.Value.Date == DateTime.Now.Date.AddDays(-1))
                        {
                            str = string.Format("<span style='color:red;font-style:italic;'>{0}</span>", str);
                        }
                    }

                    // If Yesturday's date show in red italics
                    // Add add-hoc formating
                    if (row.IsIssueAdHoc)
                    {
                        if (formatOption.ToLower().Contains("highlight_adhoc_grid"))
                        {
                            str = string.Format("<span style='color:red;font-weight:bold;' title='Ad-Hoc issue'>AH</span> {0}", str);
                        }
                        else if (formatOption.ToLower().Contains("text_adhoc_panel"))
                        {
                            str = string.Format("{0} <span style='color:red;font-weight:bold;' title='Ad-Hoc issue'>(Ad-Hoc)</span>", str);
                        }
                        else
                        {
                            str = string.Format("<span title='Ad-Hoc issue'>{0}</span>", str);
                        }
                    }

                    // hyperlink that calls method lastIssueDate_click(WWardProductListLineID, fromDate, toDate)
                    if (formatOption.ToLower().Contains("hyperlink"))
                    {
                        string fromDate = row.LastIssueDate.ToStartOfDay().Value.ToString("yyyy,MM - 1,dd,HH,mm,ss");
                        string toDate   = row.LastIssueDate.ToEndOfDay  ().Value.ToString("yyyy,MM - 1,dd,HH,mm,ss");
                        str = string.Format("<{4} href='javascript:void(0)' onclick='lastIssueDate_click({0}, new Date({1}), new Date({2}))' style='cursor:hand;'>{3}</{4}>", row.WWardProductListLineID, fromDate, toDate, str, row.IsMultiIssueOnIssueDate ? "a" : "span");
                    }
                }

                return str;
                }

            case "{linecost}":
                WProductRow drug = this.productInList.FindBySiteIDAndNSVCode(SessionInfo.SiteID, row.NSVCode);
                int     productConversionFactor = drug.ConversionFactorPackToIssueUnits;
                int     lineConversionFactorPack= row.GetConversionFactorPackToIssueUnits().Value;
                decimal lineCostExVatPerPack    = (drug.AverageCostExVatPerPack * lineConversionFactorPack) / productConversionFactor;
                decimal lineTotalExVat          = row.TopupLvl * lineCostExVatPerPack;
                decimal vatRate                 = (drug.VATRate ?? 1);

                switch (formatOption.ToLower())
                {
                case "cost per pack (for line)": return string.Format("{0} for 1 x {1} {2}", lineCostExVatPerPack.ToMoneyString(this.moneyDisplayType), lineConversionFactorPack, drug.PrintformV);
                case "line cost ex vat"        : return lineTotalExVat.ToMoneyString(this.moneyDisplayType);
                case "line cost inc vat"       : return (lineTotalExVat * vatRate).ToMoneyString(this.moneyDisplayType);
                case "line cost showing vat"   : decimal vatValue = (lineTotalExVat * (vatRate - 1));
                                                 return string.Format("{0} + {1} {2} = {3}", lineTotalExVat.ToMoneyString(this.moneyDisplayType), 
                                                                                             vatValue.ToMoneyString(this.moneyDisplayType),
                                                                                             PharmacyCultureInfo.SalesTaxName,
                                                                                             (lineTotalExVat + vatValue).ToMoneyString(this.moneyDisplayType));                                                                                             
                }
                break;

            case "inuse_productstock":
                {
                if (!row.InUse_ProductStock && formatOption.ToLower().Contains("highlight"))
                {
                    return "<span style='color:red;font-style:italic;'>Not In Use</span>";
                }
                }
                break;
            }

            return QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);
        }
        #endregion

        #region QSBaseProcessor Methods
        /// <summary>Returns a list of data field indexes whose values must be filled in by user</summary>
        public override HashSet<int> GetRequiredDataIndexes(QSView qsView)
        {
            HashSet<int> requiredDataIndex = new HashSet<int>();
            requiredDataIndex.Add(DATAINDEX_DESCRIPTION );
            requiredDataIndex.Add(DATAINDEX_PACKSIZE    );
            requiredDataIndex.Add(DATAINDEX_QUANTITY    );
            requiredDataIndex.Add(DATAINDEX_DISPLAYINDEX);
            return requiredDataIndex;
        }

        /// <summary>Called to update qsView with all the values (from processor data)</summary>
        public override void PopulateForEditor(QSView qsView)
        {
            foreach(int ID in this.Lines.Select(l => l.WWardProductListLineID))
            {
                var row = Lines.FindByID(ID);

                foreach(var qsDataInputItem in qsView)
                    qsDataInputItem.SetValueBySiteID(ID, this.GetValueForEditor(row, qsDataInputItem.index));
            }
        }

        /// <summary>Returns mapped data index value as string</summary>
        public string GetValueForEditor(BaseRow row, int index)
        {
            try
            {
                WWardProductListLineRow line = row as WWardProductListLineRow;
                switch (index)
                {
                case DATAINDEX_DESCRIPTION: return line.Description.TrimEnd();
                case DATAINDEX_PACKSIZE:    return line.ConversionFactorPackToIssueUnits.ToString();
                case DATAINDEX_QUANTITY:    return line.TopupLvl.ToString();
                case DATAINDEX_PRINTLABEL:  return EnumDBCodeAttribute.EnumToDBCode(line.PrintLabel);
                case DATAINDEX_COMMENTS:    return line.Comment;
                case DATAINDEX_DISPLAYINDEX:return (line.DisplayIndex + 1).ToString();
                }
            }
            catch(Exception)
            {
            }

            return string.Empty;
        }

        /// <summary>Call to setup all the lookups in QSView</summary>
        public override void SetLookupItem(QSView qsView) { }

        /// <summary>Called to validate the web controls in QSView</summary>
        /// <returns>Returns list of validation error or warnings</returns>
        public override QSValidationList Validate(QSView qsView)
        {
            QSValidationListForLine         validationInfo  = new QSValidationListForLine(this.Lines);
            WWardProductListLineColumnInfo  columnInfo      = WWardProductListLine.GetColumnInfo();
            HashSet<int>                    required        = this.GetRequiredDataIndexes(qsView);

            foreach (var ID in this.Lines.Select(l => l.WWardProductListLineID))
            {
                var row = Lines.FindByID(ID);
                if (row == null)
                    continue;

                foreach(QSDataInputItem item in qsView)
                {
                    try
                    {
                        WebControl webCtrl = item.GetBySiteID(ID);  // This is correct as using WWardProductListLineID for site ID
                        if (webCtrl is Label || !item.Enabled)
                            continue;

                        string value = item.GetValueBySiteID(ID);   // This is correct as using WWardProductListLineID for site ID
                        string error = string.Empty;

                        switch(item.index)
                        {
                        case DATAINDEX_DESCRIPTION:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.DescriptionLength), out error))
                                validationInfo.AddError(ID, error);
                            break;
                        case DATAINDEX_PACKSIZE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), columnInfo.PackSizeMin, columnInfo.PackSizeMax, out error))
                                validationInfo.AddError(ID, error);
                            break;
                        case DATAINDEX_QUANTITY:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(decimal), required.Contains(item.index), columnInfo.TopupLvlMin, columnInfo.TopupLvlMax, out error))
                                validationInfo.AddError(ID, error);
                            break;
                        case DATAINDEX_COMMENTS:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.CommentLength), out error))
                                validationInfo.AddError(ID, error);
                            break;
                        case DATAINDEX_DISPLAYINDEX:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), 1, int.MaxValue, out error))
                                validationInfo.AddError(ID, error);
                            break;
                        case DATAINDEX_PRINTLABEL:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), columnInfo.PrintLabelLength, out error))
                                validationInfo.AddError(ID, error);
                            else if ( value == EnumDBCodeAttribute.EnumToDBCode(PrintLabelType.BatchBulk) )
                            {
                                // Validate if Batch Bulk is allowed

                                WWardProductList list = new WWardProductList();
                                list.LoadByID(row.WWardProductListID);

                                if ( !Settings.AllowDLO )
                                    validationInfo.AddError(ID, "Batch Bulks is invalid as DLO is not enabled");
                                else if ( !list[0].PrintPickTicket )
                                    validationInfo.AddError(ID, "Batch Bulks is invalid as list does not allow picking ticket printing.");
                            }
                            break;
                        }
                    }
                    catch (Exception ex)
                    {
                        //validationInfo.AddError(siteID, "Failed validating {0}\n{1}", item.description, ex.GetAllMessaages().Select(t => "\t" + t)); XN 26Jun14
                        validationInfo.AddError(ID, "Failed validating {0}\n{1}", item.description, ex.GetAllMessaages().ToCSVString("\n"));
                    }
                }
            }

            return validationInfo;
        }


        /// <summary>Called to get difference between QS data and (original) process data</summary>
        public override QSDifferencesList GetDifferences(QSView qsView)
        {
            QSDifferencesListForLine differences = new QSDifferencesListForLine(this.Lines);
            foreach (int ID in this.Lines.Select(l => l.WWardProductListLineID))
            {
                var row = this.Lines.FindByID(ID);

                foreach (QSDataInputItem item in qsView)
                {
                    if (item.Enabled)
                    {
                        QSDifference? difference = item.CompareValues(ID, this.GetValueForEditor(row, item.index));
                        if (difference != null)
                            differences.Add(difference.Value);
                    }
                }
            }
            return differences;
        }


        /// <summary>Save the values from QSView to the DB (or just localy)</summary>
        /// <param name="qsView">QueScrl controls that hold the data</param>
        /// <param name="saveToDB">If the qsView data is to be saved to the DB (or just updated local data)</param>
        public override void Save(QSView qsView, bool saveToDB)
        {
            QSDifferencesList differences = this.GetDifferences(qsView);
            DateTime          now         = DateTime.Now;

            foreach (int ID in this.Lines.Select(l => l.WWardProductListLineID))
            {
                WWardProductListLineRow row = this.Lines.FindByID(ID);
                if (row == null)
                    continue;

                foreach (QSDataInputItem item in qsView)
                {
                    if (!item.Enabled || item.CompareValues(ID, GetValueForEditor(row, item.index)) == null)
                        continue;

                    string value = item.GetValueBySiteID(ID);
                    switch(item.index)
                    {
                    case DATAINDEX_DESCRIPTION  : row.Description                     = value; break;
                    case DATAINDEX_PACKSIZE     : row.ConversionFactorPackToIssueUnits= int.Parse(value); break;
                    case DATAINDEX_QUANTITY     : row.TopupLvl                        = int.Parse(value); break;
                    case DATAINDEX_PRINTLABEL   : row.PrintLabel                      = EnumDBCodeAttribute.DBCodeToEnum<PrintLabelType>(value); break;
                    case DATAINDEX_COMMENTS     : row.Comment                         = value; break;
                    case DATAINDEX_DISPLAYINDEX : row.DisplayIndex                    = int.Parse(value) - 1; break;
                    }
                }
            }

            // Save
            if (saveToDB)
            {
                WWardProductList lists = new WWardProductList();
                lists.LoadByIDs( this.Lines.Select(l => l.WWardProductListID) );

                using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    this.Lines.Save(lists);
                    trans.Commit();
                }
            }
        }

        /// <summary>Writes object data to XML writer</summary>
        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
            writer.WriteElementString("MoneyDisplayType", moneyDisplayType.ToString());
            writer.WriteElementString("allowDLO",         allowDLO.ToYNString());
            this.Lines.WriteXml(writer);
        }

        /// <summary>Reads object data from XML reader</summary>
        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
            this.moneyDisplayType = (MoneyDisplayType)Enum.Parse(typeof(MoneyDisplayType), reader.ReadElementString("MoneyDisplayType"), true);
            this.allowDLO         = BoolExtensions.PharmacyParse(reader.ReadElementString("allowDLO"));
            this.Lines = new WWardProductListLine();
            this.Lines.ReadXml(reader);
        }
        #endregion
    }
}
