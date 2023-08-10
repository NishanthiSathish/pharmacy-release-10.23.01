//===========================================================================
//
//							QSDataInputItem.cs
//
//  Holds information, and has helper functions, for the QuesScrl data. 
//  This is read from WCondifuration QuesScrl Data Section (e.g. description, max lenth)
//  The class also holds all the web controls that the user can use to enter values
//
//  Unlike the vb6 version the class can be used on mutilple sites
//  So there will be 1 web control for each site.
//  Controls will be given ID QuesScrlCtrl{Data Index}_{siteID}
//
//  To load all the data from WConfiguration use QSView.Load
//  
//  For more information see QuesScrl.ascx.cs
//
//	Modification History:
//	23Jan14 XN  Written
//  17Mar14 XN  Allow checkbox to handle invalid entry 86459 
//  21Mar14 XN  Update CompareValues to always return no changes for buttons 86873
//  25Jun13 XN  Made multi line textboxes have correct number or rows depending 
//              on max length of input 88506
//  16Oct14 XN  102114 Added ForceMandatory field
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>QuesScrl control type</summary>
    internal enum QuesScrlCtrlType
    {
        None                        = -99,
        TextBox                     =  0,
        TextBox_DigitsOnly          =  1,
        TextBox_YN                  =  2,
        TextBox_DigitsAndDot        =  3,
        TextBox_DigitsAndMinus      =  4,
        TextBox_DigitsDotAndMinus   =  5,
        //TextBox_Mask                =  6,
        //TextBox_NumericMask         =  7,
        TextBox_PatterMask          =  8,
        TextBox_SingleCharCode      =  9,
        Checkbox                    =  15,
        Date                        =  20,
        Button                      =  200,
    }

    /// <summary>
    /// Represents a QuesScrl Data item 
    /// Defined in WConfiguration Section='Data'
    /// Has a Web input control of the correct type (normal TextBox) for each site
    /// </summary>
    public class QSDataInputItem
    {
        private List<WebControl> _inputControls = new List<WebControl>();

        #region Public Properties
        /// <summary>WConfiguration data index</summary>
        public int index { get; internal set; }

        /// <summary>Description given to the item</summary>
        public string description { get; internal set; }

        /// <summary>Extra description info displayed after item</summary>
        public string infoText { get; set; }

        /// <summary>Max length of input</summary>
        public int maxLength  { get; internal set; }

        /// <summary>If spacer (control type None)</summary>
        public bool isSpacer { get; internal set; }

        /// <summary>Web input control (one control of each site)</summary>
        public IEnumerable<WebControl> inputControls { get { return _inputControls; } }

        /// <summary>Get if the control is enabled</summary>
        public bool Enabled 
        { 
            get 
            { 
                WebControl control = inputControls.FirstOrDefault();
                return (control == null) ? false : control.Enabled;
            } 
        }

        /// <summary>Returns if the control is a lookup only</summary>
        public bool IsLookupOnly
        {
            get
            {
                WebControl control = inputControls.FirstOrDefault();
                return (control == null) ? false : control.Attributes.Keys.OfType<string>().Any(k => k.EqualsNoCase("lookupOnly"));
            }
        }
        
        /// <summary>
        /// If the field is forced to be mandatory
        /// NOTE: If returns false this does NOT necessarily mean that field is optional as might be hardcoded as mandatory
        /// 16Oct14 XN  102114 Added ForceMandatory field
        /// </summary>
        public bool ForceMandatory { get; internal set; }
        #endregion

        #region Public Method
        /// <summary>Returns first control from inputControls with the specified site ID</summary>
        public WebControl GetBySiteID(int siteID) 
        { 
            string siteIDStr = siteID.ToString();
            return inputControls.FirstOrDefault(s => s.Attributes["SiteID"] == siteIDStr);
        }

        /// <summary>Returns all controls with matching site IDS (maintains order)</summary>
        public IEnumerable<WebControl> GetBySiteIDs(IEnumerable<int> siteIDs)
        {
            foreach(int siteID in siteIDs)
            {
                string siteIDStr = siteID.ToString();
                foreach (WebControl webctrl in inputControls)
                {
                    if (webctrl.Attributes["SiteID"] == siteIDStr)
                        yield return webctrl;
                }
            }
        }

        /// <summary>Returns the value or the web control by siteID</summary>
        public string GetValueBySiteID(int siteID)
        {
            WebControl control = GetBySiteID(siteID);
            if (control is TextBox)
                return (control as TextBox).Text;
            else if (control is CheckBox)
                return (control as CheckBox).Checked.ToYesNoString();
            else if (control is Button)
                return (control as Button).Text;
            else if (control is Label)
                return (control as Label).Text;
            else
                throw new ApplicationException("QuesScrlParser.GetControlValue unsupported control type " + control.GetType().Name);
        }

        /// <summary>Sets input control value by siteID</summary>
        public void SetValueBySiteID(int siteID, string value)
        {
            WebControl       control  = this.GetBySiteID(siteID);
            QuesScrlCtrlType ctrlType = (QuesScrlCtrlType)Enum.Parse(typeof(QuesScrlCtrlType), control.Attributes["QuesScrlCtrlType"]);

            switch (ctrlType)
            {
            case QuesScrlCtrlType.None:     break;
            case QuesScrlCtrlType.Checkbox: var valBool = BoolExtensions.PharmacyParseOrNull(value.ToString());
                                            if (valBool != null)
                                                (control as CheckBox).Checked = valBool.Value; 
                                            break;
                                            // (control as CheckBox).Checked = BoolExtensions.PharmacyParse(value.ToString()); break; 86459  17Mar14 XN allow checkbox to handle invalid entry
            case QuesScrlCtrlType.Button:   if (!string.IsNullOrEmpty(value))
                                                (control as Button).Text  = value.ToString();                               
                                            break;
            default:                        (control as TextBox).Text = (value == null) ? string.Empty : value;         break;
            }
        }

        /// <summary>Compares original against new value, and returns the difference information</summary>
        /// <param name="siteID">Site ID for the comparison</param>
        /// <param name="originalValue">Original value</param>
        public QSDifference? CompareValues(int siteID, object originalValue)
        {
            WebControl       control  = this.GetBySiteID(siteID);
            QuesScrlCtrlType ctrlType = (QuesScrlCtrlType)Enum.Parse(typeof(QuesScrlCtrlType), control.Attributes["QuesScrlCtrlType"]);
            string was = string.Empty, now = string.Empty;

            switch (ctrlType)
            {
            case QuesScrlCtrlType.TextBox_YN:
                now = (control as TextBox).Text;
                if (originalValue == null)
                    was = string.Empty;
                else if (originalValue is bool? || originalValue is bool)
                    was = (bool)originalValue ? "Y" : "N"; 
                else 
                {
                    string valueStr = originalValue.ToString();
                    if (string.IsNullOrWhiteSpace(valueStr))
                        was = string.Empty;
                    else 
                        was = BoolExtensions.PharmacyParse(valueStr) ? "Y" : "N"; 
                }
                break;
            case QuesScrlCtrlType.TextBox: 
            case QuesScrlCtrlType.TextBox_DigitsAndDot:
            case QuesScrlCtrlType.TextBox_DigitsAndMinus:
            case QuesScrlCtrlType.TextBox_DigitsDotAndMinus:
            case QuesScrlCtrlType.TextBox_DigitsOnly:
            case QuesScrlCtrlType.TextBox_PatterMask:
            case QuesScrlCtrlType.TextBox_SingleCharCode:
                now = (control as TextBox).Text;
                was = originalValue.ToString();
                break;
            case QuesScrlCtrlType.Checkbox:    
                now = (control as CheckBox).Checked ? "Y" : "N";
                //was = BoolExtensions.PharmacyParse(originalValue.ToString()) ? "Y" : "N";    86459 17Mar14 XN allow checkbox to handle invalid entry
                var wasBool = BoolExtensions.PharmacyParseOrNull(originalValue.ToString());
                was = wasBool == null ? originalValue.ToString() : (wasBool.Value ? "Y" : "N");
                break;
            case QuesScrlCtrlType.Date:
                now = (control as TextBox).Text;
                if (originalValue is DateTime?)
                    was = ((DateTime?)originalValue).ToPharmacyDateString();
                else if (originalValue is DateTime)
                    was = ((DateTime)originalValue).ToPharmacyDateString();
                else
                    was = originalValue.ToString();
                break;
            case QuesScrlCtrlType.Button:   
                // now = (control as Button).Text;  21Mar14 XN 86873 Ignore changes as meaning less (else product editor robot config buttons will always register as differences)
                now = originalValue.ToString();
                was = originalValue.ToString();
                break;
            }            

            // If different then create QSDifferences object
            QSDifference? difference = null;
            if (was != now)
            {
                difference = new QSDifference() {  description = this.description,
                                                   dataIndex   = this.index,
                                                   siteID      = siteID,
                                                   was         = was,
                                                   now         = now };
            }
            return difference;
        }

        /// <summary>Stores lookup url in web controls LookupPage</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="format">URL page</param>
        /// <param name="args">URL string paramateres</param>
        public void SetLookupMap(int siteID, string format, params object[] args)
        {
            SetLookupMap(siteID, string.Empty, 0, format, args);
        }

        /// <summary>
        /// Stores lookup url in web controls LookupPage
        /// If url returns a csv list of values, it allows selection of single item from the list
        /// e.g. if url returns
        /// 232|FGH453D|Paracetamoel
        /// to selct the NSVCode set
        /// resultSeparator = |
        /// resultIndex     = 1
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="resultSeparator">Separator used for results returned by the url</param>
        /// <param name="resultIndex">0 based index for the result to use</param>
        /// <param name="format">URL page</param>
        /// <param name="args">URL string paramateres</param>
        public void SetLookupMap(int siteID, string resultSeparator, int resultIndex, string format, params object[] args)
        {
            string lookupPage = args.Length == 0 ? format : string.Format(format, args);
            GetBySiteID(siteID).Attributes["LookupPage"]        = lookupPage;
            GetBySiteID(siteID).Attributes["LookupResultIndex"] = resultIndex.ToString();

            // empty if url does not return value
            if (!string.IsNullOrEmpty(resultSeparator))
                GetBySiteID(siteID).Attributes["LookupResultSeparator"] = resultSeparator;
        }
        #endregion

        #region Internal Method
        /// <summary>
        /// Convert QuesScrlControl info into a web input control of the appropriate type
        /// Page that hosts these controls shold use QuesScrl.js for the custom mask functions
        /// Controls will be given ID QuesScrlCtrl{Data Index}_{siteID}
        /// </summary>
        internal void AddControl(QuesScrlCtrlType ctrlType, int index, int siteID, string defaultValue, int maxLength, bool upperCase, string customMask, bool enabled, bool lookupOnly, string toolTip)
        {
            const int MaxTextBoxCharsPerRow = 25;   // this is the max number of chars that can be display in single line textbox at min width of 200px
            const int MaxTextBoxRows        = 10;   // max number of textbox rows
            WebControl ctrl = null;

            switch (ctrlType)
            {
            case QuesScrlCtrlType.None:
                ctrl = new Label();
                (ctrl as Label).Text = "&nbsp;";
                break;
            case QuesScrlCtrlType.Checkbox:  
                ctrl = new CheckBox();
                if (!string.IsNullOrWhiteSpace(defaultValue))
                    (ctrl as CheckBox).Checked = BoolExtensions.PharmacyParse(defaultValue.SafeSubstring(0, 1));
                break;
            case QuesScrlCtrlType.Button:    
                ctrl = new Button();
                (ctrl as Button).Text = defaultValue;
                (ctrl as Button).Width= new Unit(125);
                break;
            default:
                ctrl = new TextBox();
                (ctrl as TextBox).MaxLength = maxLength;
                (ctrl as TextBox).TextMode  = (MaxTextBoxCharsPerRow >= maxLength) ? TextBoxMode.SingleLine : TextBoxMode.MultiLine;
                (ctrl as TextBox).Text      = defaultValue;
                (ctrl as TextBox).Rows      = Math.Min((int)Math.Ceiling((double)maxLength / (double)MaxTextBoxCharsPerRow), MaxTextBoxRows); // Calclate the number of row to display  XN 25Jun14 88506
                (ctrl as TextBox).Width     = new Unit(190);    // Min width is 200 so leave slight gap of 10 (set here rather than on resize so does not slow things down)  XN 25Jun14 88506

                if (lookupOnly)
                {
                    ctrl.Attributes["lookupOnly"] = "lookupOnly";
                    ctrl.Attributes["onkeyup"]    += "if (event.keyCode == 112 && event.shiftKey) { DoLookup(this); };";
                }

                if (upperCase)
                {
                    ctrl.Attributes["onKeyPress"] += "ConvertToUpper();";
                    ctrl.Attributes["onPaste"]    += "ConvertToUpper();";
                }

                // Set mask info
                string modifiers = string.Empty;
                string mask      = "undefined";
                switch (ctrlType)
                {
                case QuesScrlCtrlType.TextBox_YN                : mask = "'^[YN]?$'";               break;
                case QuesScrlCtrlType.TextBox_DigitsOnly        : mask = "digitsMask";              break;
                case QuesScrlCtrlType.TextBox_DigitsAndDot      : mask = "digitsAndDotMask";        break;
                case QuesScrlCtrlType.TextBox_DigitsAndMinus    : mask = "digitsAndMinusMask";      break;
                case QuesScrlCtrlType.TextBox_DigitsDotAndMinus : mask = "digitsDotAndMinusMask";   break;      
                case QuesScrlCtrlType.TextBox_PatterMask        : mask = "undefined";               break;      /* Pattern match is handled server side */
                case QuesScrlCtrlType.TextBox_SingleCharCode    : 
                    mask = "'^[" + customMask + "]?$'";   
                    if (customMask == customMask.ToUpper())
                        modifiers = "i";
                    break;
                }   

                // always set mask
                (ctrl as TextBox).Attributes["onkeypress"] += string.Format("MaskInput(this, {0}, '{1}', {2});", mask, modifiers, maxLength);
                (ctrl as TextBox).Attributes["onpaste"]    += string.Format("MaskInput(this, {0}, '{1}', {2});", mask, modifiers, maxLength);                    
                break;
            }

            ctrl.Attributes["ctrlType"] = ctrlType.ToString();

            ctrl.Enabled = !enabled;
            if (index != 0)
                ctrl.ID = string.Format("QuesScrlCtrl{0:0000}_{1:0000}", index, siteID);
            
            ctrl.Attributes["SiteID"   ] = siteID.ToString();
            ctrl.Attributes["Index"    ] = index.ToString();
            ctrl.Attributes["QuesScrlCtrlType" ] = ctrlType.ToString();
            if (!string.IsNullOrWhiteSpace(toolTip))
                ctrl.ToolTip = toolTip;

            _inputControls.Add(ctrl);
        }
        #endregion
    }
}
