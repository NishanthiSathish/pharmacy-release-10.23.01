//===========================================================================
//
//							    Enums.cs
//
//  Provides a single location to share enumerated types between all the layers,
//  instead of duplicating the information.
//
//	Modification History:
//	28May09 XN  Written
//  29May09 XN  Added OrderStatusType to file
//  01Jun09 XN  Expaneded list of OrderStatusTypes
//  11Jun09 XN  Added PrintLabelType
//  21Jul09 XN  Added FormularyType, BatchTrackingType, MoneyDisplayType, and 
//              OrderlogKind
//  24Jul09 XN  Filled out PrintLabelType
//  21Dec09 XN  Added OrderUrgencyType, OrderInternalMethodType, PricingType 
//              enums (F0042698)
//  18Mar10 XN  F0080744 fixed problem with robot item not at top of order info screen
//              F0080745 add manual robot loading item
//  04Apr12 AJK 30998 Added new BatchStatus: Combined
//  05Jul13 XN  27252 Added PharmacyLogType
//  01Nov13 XN  Added Enum PageOrientation
//  09Nov14 XN  Added PharmacyLogType.PharmacyLog
//  02Sep14 XN  added SupplierMethod.HUB
//  31Oct14 XN  Added SupplierNameType 102842
//  04Nov14 XN  Marked SupplierType.List and SupplierType.Ward as Obsolete
//  28Nov14 XN  Added SupplierMethod.Paper 
//  06Feb15 XN  Removed SupplierMethod.Paper 110710.
//  18Feb15 XN  Added PrintLabelType.DLO db code 'D' 111397 
//  26Aug16 XN  Updates to BatchTrackingType 161234 
//===========================================================================
using System;

namespace ascribe.pharmacy.shared
{
    /// <summary>State of a stock take (used by db tables ProductStock, and WProduct)</summary>
    public enum StockTakeStatusType
    {
        [EnumDBCode("")]   Unknown, 
        [EnumDBCode("0")]  Waiting,
        [EnumDBCode("1")]  InProgress,
        [EnumDBCode("2")]  Completed,
    }

    /// <summary>urgency type</summary>
    public enum OrderUrgencyType
    {
        /// <summary>null or empty db code</summary>
        [EnumDBCode("")]  Unknown,
    }

    /// <summary>Internal method ordering needs expanding</summary>
    public enum OrderInternalMethodType
    {
        /// <summary>null or empty db code</summary>
        [EnumDBCode("")]  Unknown,
        [EnumDBCode("E")] E,
        [EnumDBCode("I")] I,
        [EnumDBCode("V")] V,
        [EnumDBCode("M")] M,
    }

    /// <summary>order status type</summary>
    public enum OrderStatusType
    {
        /// <summary>null or empty db code</summary>
        [EnumDBCode("")]  Unknown,

        /// <summary>
        /// WOrder item
        /// db code '1'
        /// </summary>
        [EnumDBCode("1")] WaitingAuthorisation,

        /// <summary>
        /// WOrder item
        /// Items made into transord.txt but transmission no confirmed. 
        /// Db code '2'
        /// </summary>
        [EnumDBCode("2")] WaitingTransmissionConfirmation,

        /// <summary>
        /// WOrder item
        /// Waiting for order to come from supplier. 
        /// Db code '3'
        /// </summary>
        [EnumDBCode("3")] WaitingToReceive,

        /// <summary>
        /// WReconcil item
        /// for invoice reconciliation
        /// db code '4'
        /// </summary>
        [EnumDBCode("4")] Received, 

        /// <summary>
        /// WRequisition item
        /// db code '5'
        /// </summary>
        [EnumDBCode("5")] Five,

        /// <summary>
        /// WRequis item
        /// db code '6'
        /// </summary>
        [EnumDBCode("6")] Six,

        /// <summary>
        /// WReconcil, or WRequis item
        /// Reconciled coding slip not printed
        /// db code '7'
        /// </summary>
        [EnumDBCode("7")] WaitingPrintout,

        /// <summary>
        /// slip printed awaiting cul on app date
        /// WReconcil, or WRequis item
        /// db code '8'
        /// </summary>
        [EnumDBCode("8")] WaitingCulOnAppDate,

        /// <summary>
        /// WOrder item
        /// Item to be returned to supplier. 
        /// Db code '9'
        /// </summary>
        [EnumDBCode("9")] Return,

        /// <summary>
        /// WReconcil, or WRequis item
        /// db code 'R'
        /// </summary>
        [EnumDBCode("R")] Completed,

        /// <summary>db code 'D'</summary>
        [EnumDBCode("D")] Deleted,
    }

    /// <summary>
    /// Enumerator for the Batch Status from lookup table RepeatDispensingBatchStatus
    /// </summary>
    [EnumViaDBLookup(TableName = "RepeatDispensingBatchStatus", PKColumn = "StatusID", DescriptionColumn = "Code")]
    public enum BatchStatus
    {
        [EnumDBDescription("N")] New,
        [EnumDBDescription("L")] Labelled,
        [EnumDBDescription("I")] Issued,
        [EnumDBDescription("A")] Archived,
        [EnumDBDescription("D")] Deleted,
        [EnumDBDescription("P")] Incomplete,
        [EnumDBDescription("C")] Combined
    }

    /// <summary>
    /// SupplyPatternID enumerator for repeat dispensing patient settings
    /// </summary>
    [EnumViaDBLookup(TableName = "RepeatDispensingSupplyPatterns", PKColumn = "SupplyPatternID", DescriptionColumn = "Description")]
    public enum SupplyPattern
    {
        [EnumDBDescription("Single Supply")] SingleSupply,
        [EnumDBDescription("Daily increments")] Daily,
        [EnumDBDescription("7 day increments")] SevenDay,
        [EnumDBDescription("7 day increments as 3 days and 4 days")] SevenDay3and4,
        [EnumDBDescription("7 day increments as 4 days and 3 days")] SevenDay4and3,
        [EnumDBDescription("14 day increments")] FourteenDay,
        [EnumDBDescription("21 day increments")] TwentyOneDay,
        [EnumDBDescription("28 day increments")] TwentyEightDay
    }

    /// <summary>Type of supplier</summary>
    public enum SupplierType
    {
        [EnumDBCode("")]  Unknown,

        /// <summary>External supplier type</summary>
        [EnumDBCode("E")] External,

        /// <summary>Internal cost centre</summary>
        [EnumDBCode("S")] Stores,

        /// <summary>Virtual list used to group drugs</summary>
        [Obsolete("Lists have now been moved to WWardProductList")]
        [EnumDBCode("L")] List,
 
        /// <summary>Drug on specific ward</summary>
        [Obsolete("Ward have now been moved to WCustomer (though still present in view WSupplier)")]
        [EnumDBCode("W")] Ward,
    }

    /// <summary>Supplier ordering method</summary>
    public enum SupplierMethod
    {
        [EnumDBCode("")]  Unknown,

        [EnumDBCode("F")] Fax,

        /// <summary>Direct or Paper based (P in the editor)</summary>
        [EnumDBCode("D")] Direct,
        
        [EnumDBCode("E")] EDI,
        [EnumDBCode("I")] Internal,

        /// <summary>Fast transfer between sites</summary>
        [EnumDBCode("T")] Transfer,

        [EnumDBCode("H")] HUB,

        /// <summary>Ordered by modem</summary>
        [System.Obsolete("Not currently used")]
        [EnumDBCode("M")] Modem,
    }

    /// <summary>WardStock's print label type</summary>
    public enum PrintLabelType
    {
        /// <summary>DB code "" or "~" etc</summary>
        [EnumDBCode("")]    NoLabel,

        /// <summary>DB code P</summary>
        [EnumDBCode("P")]   PrintLabel, 

        /// <summary>DB code B</summary>
        [EnumDBCode("B")]   BatchBulk, 

        /// <summary>DB code D 111397 18Feb15 XN</summary>
        [EnumDBCode("D")] DLO,
    }


    /// <summary>Used to specify the formulary type to use</summary>
    public enum FormularyType
    {
        [EnumDBCode("")] Unknown,
        [EnumDBCode("Y")] Yes,
        [EnumDBCode("N")] No,
        [EnumDBCode("R")] Restricted,
        [EnumDBCode("C")] Consultant,
        [EnumDBCode("S")] Specialised,
    }

    /// <summary>ProductStock, and WProduct batch tracking type</summary>
    public enum BatchTrackingType
    {
        /// <summary>
        /// When db code is null, empty, or 0
        /// 26Aug16 161234 No long covers state 1
        /// </summary>
        [EnumDBCode("0")] None,

        /// <summary>
        /// Db code 1
        /// 26Aug16 161234 Added
        /// </summary>
        [EnumDBCode("1")] One,

        /// <summary>
        /// Record Batch on Receipt
        /// Db code 2
        /// </summary>
        [EnumDBCode("2")] OnReceipt,

        /// <summary>
        /// Record Batch and Expiry on Receipt
        /// Db code 3
        /// </summary>
        [EnumDBCode("3")] OnReceiptWithExpiry,

        /// <summary>
        /// Record Batch and Expiry on Receipt & Confirm on Issue
        /// Db code 4
        /// </summary>
        [EnumDBCode("4")] OnReceiptWithExpiryAndConfirm
    }

    /// <summary>ProductStock, and WProduct pricing used for a drug</summary>
    public enum PricingType
    {
        [EnumDBCode("M")]
        Manual,

        [EnumDBCode("Y")]
        Automatic,

        [EnumDBCode("N")]
        None,
    }

    /// <summary>Used to determine if costs are displayed (normaly by the ToMoneyString extension methods)</summary>
    public enum MoneyDisplayType
    {
        /// <summary>Cost is displayed as normal</summary>
        Show,               

        /// <summary>Cost value is not to be displayed (normally replace by '*****')</summary>
        Hide,

        /// <summary>Cost value is not displayed (normally replaced by ' *****' with leading space)</summary>
        HideWithLeadingSpace,
    }

    /// <summary>If the item is suitable for loading on a robot</summary>
    public enum RobotItem
    {
        /// <summary>Item can be loaded automatically by robot</summary>
        Automatic,

        /// <summary>Item is a robot item but must be loaded manually (normally as requires batch tracking)</summary>
        Manual, 

        /// <summary>Not a robot item</summary>
        No,
    }

    /// <summary>Gender type of a person</summary>
    [EnumViaDBLookup(TableName="Gender", PKColumn="GenderID", DescriptionColumn="Description")]
    public enum GenderType
    {
        [EnumDBDescription("Unknown")] Unknown,
        [EnumDBDescription("Male"   )] Male,
        [EnumDBDescription("Female" )] Female, 
        [EnumDBDescription("Other"  )] Other
    }

    /// <summary>
    /// Pharmacy log type (Worderlog, WTranslog, WPharmacyLog)
    /// 05Jul13 XN 27252 
    /// </summary>
    public enum PharmacyLogType
    {
        [EnumDBCode("")]  Unknown,

        /// <summary>DB code 'O'</summary>
        [EnumDBCode("O")]  Orderlog,

        /// <summary>DB code 'T'</summary>
        [EnumDBCode("T")] Translog,

        /// <summary>DB code 'P'</summary>
        [EnumDBCode("P")] PharmacyLog,
    }


    /// <summary>Orientation of the page</summary>
    public enum PageOrientation
    {
        Landscape,
        Portrait
    }

    /// <summary>
    /// Supplier name type to display read from WConfiguration setting
    /// Category: D|Winord
    /// Section: defaults
    /// Key: SupplierShortName    
    /// 
    /// if value is B           then SupplierNameType.ShortAndLongName
    /// if value is Y. T, 1, -1 then SupplierNameType.ShortName
    /// All others SupplierNameType.FullName
    /// 31Oct14 XN  102842
    /// </summary>
    public enum SupplierNameType
    {
        FullName,        // Default to full name so use this first
        ShortName,
        ShortAndLongName
    }
}
