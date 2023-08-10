//===========================================================================
//
//							        ArxRowaRobot.cs
//
//  Handled messags from an Arx Rowa Robot.
//  The robot exects the following message (each requires a template in the 
//  RobotLoadingMsgTemplate table, with robot name "Rowa")
//      AskNewDeliver    - message requires a LoadingNumber data tag
//                         Check loading number is present in the OrderLoading
//                         sends a ReplyNewDeliveryValid or ReplyNewDeliveryInvalid reply
//      AskDrugInputRight- message requires a LoadingNumber and Barcode tag
//                         Check the proudct barcode is on the OrderLoading
//                         and items can still be added to the order and sends
//                         either a ReplyInputRightAllowed, or ReplyInputRightNotAllowed reply
//      AskDrugReturnRight-message requires a Barcode tag
//      WarnEndOfDelivery- message requires a LoadingNumber 
//                         replies with ReplyItemTakenByIT
//      CaseOfStockReturn- message requirs a drug barcode
//                         replies with ReplyItemTakenByIT
//      CaseOfNewDelivery- message requires a LoadingNumber and Barcode tag
//                         process the deliver and replies with ReplyItemTakenByIT
//      AskDrugInfo      - message requires a LoadingNumber and Barcode tag
//                         not really supported so replies with ReplyDrugInfoNotFound
//
//  Reply messages are also stored in the RobotLoadingMsgTemplate table.
//      ReplyNewDeliveryValid   - Reply given if AskNewDeliver is valid
//      ReplyNewDeliveryInvalid - Reply given if AskNewDeliver is invalid.
//                                Normaly contains extra [Error] tag
//      ReplyDrugInfoNotFound   - Reply given to all AskDrugInfo messages
//      ReplyDrugAllowed        - Reply given if AskDrugReturnRight is valid 
//      ReplyDrugNotAllowed     - Reply given if AskDrugReturnRight is invalid
//                                Normaly contains extra [ErrorCode] and [Error] tags
//      ReplyItemTakenByIT      - Generic reply for number of messages
//
//	Modification History:
//	16Dec09 XN  Written
//  30Jan10 XN  Used ProductStock.LocCode, instead of WOrder.LocCode also added 
//              check that robot item does not support batch tracking.
//  16Jun11 XN  added message to send all errors to robot
//              added testing locked state when asking to recieve drug
//  02Oct13 XN  74592 Upgrade of Pharamcy to .NET4 means robot loader does
//              not work with the EIE which is still .NET2
//              Fixed by moving the robot loader reply component to the web site
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.robotloading;
using ascribe.pharmacy.shared;
//using ascribeplc.interfaces.common.Logger;
using ascribe.pharmacy.icwdatalayer;
//using ascribeplc.interfaces.common.messagecomponent;

namespace ascribe.interfaces.replycomponents.robotloaderreplycomponent
{
    /// <summary>
    /// Used to hold cached data for the AskDrugInputRight message
    /// This is because this message can be sent many times so 
    /// </summary>
    internal struct AskDrugInputRightCache
    {
        /// <summary>Loading number for the message</summary>
        public  int      receivedLoadingNumber;

        /// <summary>Barcode for the message</summary>
        public  string   receivedBarcode;

        /// <summary>If the drug is allowed</summary>
        public  bool     replyAllowed;

        /// <summary>If reply should indicate that loading number was missing</summary>
        public  bool     replyMissingLoadingNumber;

        /// <summary>Error message for reply</summary>
        public  string   replyErrorMessage;

        /// <summary>Last update time of message</summary>
        private DateTime lastUpdatedTime;

        /// <summary>
        /// Returns if the loading number and barcode matches the values in the cache
        /// Will also return false if the cached data has expired (after 3secs)
        /// </summary>
        /// <param name="loadingNumber">Loading number</param>
        /// <param name="barcode">Barcode</param>
        /// <returns>If loading number and barcode match</returns>
        public bool IsMatchingMessage(int loadingNumber, string barcode)
        {
            return (this.receivedLoadingNumber == loadingNumber) && (this.receivedBarcode == barcode) && ((DateTime.Now - lastUpdatedTime).TotalSeconds < 3.0);
        }

        /// <summary>Set the cached data.</summary>
        /// <param name="loadingNumber">Message loading number</param>
        /// <param name="barcode">Message barcode</param>
        /// <param name="allowed">If message is allowed</param>
        /// <param name="missingLoadingNumber">If repy indicates that the laoding number is missing</param>
        /// <param name="errorMessage">Error message for the reply</param>
        public void Set(int loadingNumber, string barcode, bool allowed, bool missingLoadingNumber, string errorMessage)
        {
            this.receivedLoadingNumber      = loadingNumber;
            this.receivedBarcode            = barcode;
            this.replyAllowed               = allowed;
            this.replyMissingLoadingNumber  = missingLoadingNumber;
            this.replyErrorMessage          = errorMessage;
            this.lastUpdatedTime            = DateTime.Now;
        }

        /// <summary>Clears all the cached data</summary>
        public void Clear()
        {
            this.receivedLoadingNumber      = -1;
            this.receivedBarcode            = string.Empty;
            this.replyAllowed               = false;
            this.replyMissingLoadingNumber  = false;
            this.replyErrorMessage          = string.Empty;
        }
    };

    /// <summary>Used to handle the HL7 message from a arx rowa robot</summary>
    internal class RowaRobot : BaseRobot
    {
        #region Constants
        /// <summary>Robot name</summary>
        public const string Name = "Rowa";

        // Tags used in the message templates
        private const string DATATAG_MESSAGECONTROLID   = "MessageControlID";
        private const string DATATAG_LOADINGNUMBER      = "LoadingNumber";
        private const string DATATAG_DRUGBARCODE        = "DrugBarcode";
        private const string DATATAG_ERRORCODE          = "ErrorCode";
        private const string DATATAG_ERROR              = "Error";

        // Names of the replay templates
        private const string REPLY_NEWDELIVERVALID      = "ReplyNewDeliveryValid";
        private const string REPLY_NEWDELIVERINVALID    = "ReplyNewDeliveryInvalid";
        private const string REPLY_DRUGINFONOTFOUND     = "ReplyDrugInfoNotFound";
        private const string REPLY_INPUTALLOWED         = "ReplyDrugAllowed";
        private const string REPLY_INPUTNOTALLOWED      = "ReplyDrugNotAllowed";
        private const string REPLY_ITEMTAKENBYIT        = "ReplyItemTakenByIT";
        private const string REPLY_ERROR                = "ReplyError";

        // Standard error messages
        private const string ERRORMSG_TEMPLATEMISSINGDATATAG = "Tag [{0}] is either missing from message template, or failed to decode message correctly.";
        private const string ERRORMSG_INVALIDDELIVERNUMBER   = "Invalid loading number '{0}'";
        private const string ERRORMSG_INVALIDBARCODE         = "Invalid barcode '{0}' for this loading '{1}'";
        private const string ERRORMSG_INVALIDORDERCLOSED     = "Cannot receive any more of this item as the total ordered has been received. (Order number '{0}', NSV code '{1}')";
        private const string ERRORMSG_INVALIDLOCATION        = "Not set as a robot product in Pharmacy. Current  location is '{0}'.";        
        #endregion

        #region Member variables
        /// <summary>Used to store the control ID of the previous message</summary>
        private string messageControlID = string.Empty;

        /// <summary>Last message received</summary>
        private string lastReceivedMessageType = string.Empty;

        /// <summary>Cached ask drug input right</summary>
        private AskDrugInputRightCache lastAskDrugInputRight = new AskDrugInputRightCache();

        /// <summary>Cached ask drug return right</summary>
        private AskDrugInputRightCache lastAskDrugReturnRight = new AskDrugInputRightCache();        
        #endregion

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="log">interface engine application log</param>
        /// <param name="config">interface engine condifugration information</param>
        public RowaRobot(EIELogger log, Config config) : base(Name, log, config) { }

        /// <summary>Processes the message and sends out a reply</summary>
        /// <param name="messageID">Message ID</param>
        /// <param name="messageText">Message</param>
        /// <returns>Reply generated</returns>
        public override string GenerateReply(Guid messageID, string messageText)
        {
            Dictionary<string, string> mapper = new Dictionary<string,string>();
            IEnumerable<string> messageTypes;
            string matchedMsgType;
            string replyMessage = null;

            try
            {
                // Works out what type of message received
                messageTypes = this.decoder.DecodeMessage(messageText, mapper);
                if (messageTypes.Count() == 0)
                    throw new ApplicationException("Failed to match message to a template");
                if (messageTypes.Count() > 1)
                {
                    // If message matched to more than one type then list all the type in the error
                    StringBuilder error = new StringBuilder("Failed to match message, to one particular type. Message was matched to");
                    foreach (string messageType in messageTypes)
                        error.AppendFormat(" {0},", messageType);
                    throw new ApplicationException(error.ToString());
                }

                // Get the message type
                matchedMsgType = messageTypes.First();

                // Validate the message control ID
                if (!string.IsNullOrEmpty(matchedMsgType))
                    ValidateMessageControlID(mapper);

                // Process the message
                switch (matchedMsgType.ToLower())
                {
                case "asknewdeliver"        : replyMessage = ProcessAskNewDeliveryMsg       (messageID, mapper);                break;
                case "askdruginputright"    : replyMessage = ProcessAskDrugInputRightMsg    (messageID, mapper, matchedMsgType);break;
                case "askdrugreturnright"   : replyMessage = ProcessAskDrugReturnRightMsg   (messageID, mapper, matchedMsgType);break;
                case "warnendofdelivery"    : replyMessage = ReplyItemTakenByITMsg          (mapper);                           break;
                case "caseofstockreturn"    : replyMessage = ReplyDrugAllowedMsg            (true, false, mapper, string.Empty);break;
                case "caseofnewdelivery"    : replyMessage = ProcessNewDeliveryMsg          (messageID, mapper);                break;
                case "askdruginfo"          : replyMessage = ReplyDrugInfo                  (mapper);                           break;
                default: throw new ApplicationException(string.Format("Unsupported message type {0}.", matchedMsgType));
                }

                // remember the last message type
                lastReceivedMessageType = matchedMsgType;
            }
            catch (Exception ex)
            {
                log.LogError(SessionInfo.SessionID, base.config.InterfaceComponentId, ex, 0, string.Empty, messageID);
                replyMessage = ReplyError(mapper, ex.Message);
            }

            return replyMessage;
        }

        /// <summary>Throws exception if the message conrol ID has been seen before.</summary>
        /// <param name="mapper">Message data tag dictionary</param>
        public void ValidateMessageControlID(Dictionary<string, string> mapper)
        {
            // If the tag does not exist then was not read from message so error
            if (!mapper.ContainsKey(DATATAG_MESSAGECONTROLID))
            {
                string error = string.Format(ERRORMSG_TEMPLATEMISSINGDATATAG, DATATAG_MESSAGECONTROLID);
                throw new ApplicationException(error);
            }

            // If the message control ID has been seen before then error
            if (mapper[DATATAG_MESSAGECONTROLID] == messageControlID)
                throw new ApplicationException("Repeated message control ID");

            // Cache the new control ID
            messageControlID = mapper[DATATAG_MESSAGECONTROLID];
        }    

        /// <summary>
        /// Processes the ask for new deliver message
        /// Check that the loading number is correct, and send the appropriate reply
        /// </summary>
        /// <param name="messageID">Message ID</param>
        /// <param name="mapper">Message data tag dictionary</param>
        /// <returns>HL7 reply</returns>
        public string ProcessAskNewDeliveryMsg (Guid messageID, Dictionary<string, string> mapper)
        {
            bool   valid        = false;
            string errorMessage = string.Empty;
            int    loadingNumber= -1;

            try
            {
                // Get the loading number
                if (!mapper.ContainsKey(DATATAG_LOADINGNUMBER))
                {
                    string error = string.Format(ERRORMSG_TEMPLATEMISSINGDATATAG, DATATAG_LOADINGNUMBER);
                    throw new ApplicationException(error);
                }

                string loadingNumberStr = mapper[DATATAG_LOADINGNUMBER];
                if (!int.TryParse(loadingNumberStr, out loadingNumber))
                {
                    string error = string.Format(ERRORMSG_INVALIDDELIVERNUMBER, loadingNumberStr);
                    throw new ApplicationException(error);
                }

                // determine if the loading number is valid
                OrderLoadingRow orderLoading = OrderLoading.GetBySiteAndLoadingNumber(SessionInfo.SiteID, loadingNumber);
                if (orderLoading == null)
                {
                    string error = string.Format(ERRORMSG_INVALIDDELIVERNUMBER, loadingNumber);
                    throw new ApplicationException(error);
                }

               // Test if loading is complete
                if (orderLoading.Status == OrderLoadingStatus.Completed)
                    throw new ApplicationException("Loading has been marked as complete.");

                // Everything passed so loading is valid
                valid = true;
            }
            catch (Exception ex)
            {
                errorMessage = AddMessageError(ex, messageID, -1, string.Empty);
            }

            // send new delivery reply
            return ReplyNewDeliveryMsg(valid, mapper, errorMessage);
        }

        /// <summary>
        /// Process ask for drug input message
        /// Checks that the drug is on the loading, and items can still be received for the order
        /// As this message is repeated multiple times the details of the message and it's reply
        /// will be cached and used if appropriate for repeated messages
        /// </summary>
        /// <param name="messageID">Message ID</param>
        /// <param name="mapper">Message data tag dictionary</param>
        /// <param name="messageType">type of message</param>
        /// <returns>HL7 reply</returns>
        public string ProcessAskDrugInputRightMsg (Guid messageID, Dictionary<string, string> mapper, string messageType)
        {
            bool   allowed              = false;
            bool   missingLoadingNumber = true;
            string errorMessage         = string.Empty;
            int    loadingNumber        = -1;
            string drugBarcode          = string.Empty;

            try
            {
                // Get the loading number
                if (!mapper.ContainsKey(DATATAG_LOADINGNUMBER))
                {
                    string error = string.Format(ERRORMSG_TEMPLATEMISSINGDATATAG, DATATAG_LOADINGNUMBER);
                    throw new ApplicationException(error);
                }

                string loadingNumberStr = mapper[DATATAG_LOADINGNUMBER];
                if (!int.TryParse(loadingNumberStr, out loadingNumber))
                {
                    string error = string.Format(ERRORMSG_INVALIDDELIVERNUMBER, loadingNumberStr);
                    throw new ApplicationException(error);
                }

                missingLoadingNumber = false;

                // Get the drug barcode
                if (!mapper.ContainsKey(DATATAG_DRUGBARCODE))
                {
                    string error = string.Format(ERRORMSG_TEMPLATEMISSINGDATATAG, DATATAG_DRUGBARCODE);
                    throw new ApplicationException(error);
                }
                drugBarcode = mapper[DATATAG_DRUGBARCODE];

                // If this is the same as a previous message the send out the same reply (and end)
                if (this.lastReceivedMessageType.Equals(messageType, StringComparison.CurrentCultureIgnoreCase) && lastAskDrugInputRight.IsMatchingMessage(loadingNumber, drugBarcode))
                {
                    // Reload the cached data
                    allowed = lastAskDrugInputRight.replyAllowed;
                    missingLoadingNumber = lastAskDrugInputRight.replyMissingLoadingNumber;
                    errorMessage = lastAskDrugInputRight.replyErrorMessage;
                }
                else
                {
                    // New message so query database again

                    // Clear existing drug info
                    lastAskDrugInputRight.Clear();

                    // Get order loading
                    OrderLoading orderLoading = new OrderLoading();
                    orderLoading.LoadBySiteAndLoadingNumber(SessionInfo.SiteID, loadingNumber);
                    if (!orderLoading.Any())
                    {
                        string error = string.Format(ERRORMSG_INVALIDDELIVERNUMBER, loadingNumber);
                        throw new ApplicationException(error);
                    }

                    // Test if loading is complete
                    if (orderLoading[0].Status == OrderLoadingStatus.Completed)
                        throw new ApplicationException("Loading has been marked as complete.");

                    // Get order
                    WOrder orders = orderLoading[0].GetOrders(drugBarcode);
                    if (!orders.Any())
                    {
                        string error = string.Format(ERRORMSG_INVALIDBARCODE, drugBarcode, loadingNumber);
                        throw new ApplicationException(error);
                    }

                    // Get if drug is valid for this location
                    ProductStock productStock = new ProductStock();
                    productStock.LoadBySiteIDAndNSVCode(orders[0].NSVCode, SessionInfo.SiteID);
                    if (productStock[0].Location != this.config.Location)
                    {
                        string error = string.Format(ERRORMSG_INVALIDLOCATION, productStock[0].Location);
                        throw new ApplicationException(error);
                    }

                    // Check that the item allows batch tracking
                    if (productStock[0].BatchTracking >= BatchTrackingType.OnReceipt)
                    {
                        string error = string.Format("Robot does not support batch tracking (Loading '{1}' barcode '{2}' NSV code '{3}')", (int)productStock[0].BatchTracking, loadingNumber, drugBarcode, orders[0].NSVCode);
                        throw new ApplicationException(error);
                    }

                    // Check order is still open
                    if (!orders.Any(i => i.CanReceive()))
                    {
                        string error = string.Format(ERRORMSG_INVALIDORDERCLOSED, orders[0].OrderNumber, orders[0].NSVCode);
                        throw new ApplicationException(error);
                    }

                    // Check if there are any outstanding items (on orders that can still receive)
                    if (!orders.Any(i => i.CanReceive() && (i.OutstandingInPacks > 0)))
                    {
                        string error = string.Format("Cannot receive any more items on this order (Order number '{0}' NSV code '{1}').", orders[0].OrderNumber, orders[0].NSVCode);
                        throw new ApplicationException(error);
                    }

                    // Test all the locking gives us a fighting chance
                    if (config.TestDBLockOnAsk)
                    {
                        using (ReceiptLineProcessor processor = new ReceiptLineProcessor())
                        {
                            using (WReconcil reconcil = new WReconcil())
                            {
                                // Get the reconcil record linked to this loading (if any)
                                reconcil.RowLockingOption = LockingOption.HardLock;
                                reconcil.LoadOpenByLoadingNumberAndPrimaryBarcode(SessionInfo.SiteID, loadingNumber, drugBarcode);

                                ReceiptLine receipt = new ReceiptLine();
                                receipt.NSVCode = orders[0].NSVCode;
                                receipt.OrderNumber = orders[0].OrderNumber;
                                receipt.QuantityInPacks = 1;
                                receipt.SiteNumber = Sites.GetNumberBySiteID(orders[0].SiteID);
                                receipt.WReconcilID = reconcil.Any() ? reconcil[0].WReconcilID : (int?)null;

                                // Normaly only add to orders that can be received on.
                                // However with Rowa if we have gone this far and no open orders left then it is too late to reject
                                // so to ignore any errors to do with closed or completd orderes
                                // This is a rare condition as it will normally be caught by the ProcessAskNewDeilverMsg.
                                receipt.AllowOverReceiving = true;
                                receipt.AllowReceivingOnCompletedOrder = true;

                                processor.Lock(receipt);
                            }
                        }
                    }

                    // All okay so
                    allowed = true;
                }
            }
            catch (Exception ex)
            {
                errorMessage = AddMessageError(ex, messageID, loadingNumber, drugBarcode);
            }
            
            // Update cached reply
            lastAskDrugInputRight.Set (loadingNumber, drugBarcode, allowed, missingLoadingNumber, errorMessage);

            // Send reply
            return ReplyDrugAllowedMsg(allowed, missingLoadingNumber, mapper, errorMessage);
        }

        /// <summary>
        /// Process ask for drug return message
        /// Checks that the drug is on a loading
        /// As this message is repeated multiple times the details of the message and it's reply
        /// will be cached and used if appropriate for repeated messages
        /// </summary>
        /// <param name="messageID">Message ID</param>
        /// <param name="mapper">Message data tag dictionary</param>
        /// <param name="messageType">type of message</param>
        /// <returns>HL7 reply</returns>
        public string ProcessAskDrugReturnRightMsg (Guid messageID, Dictionary<string, string> mapper, string messageType)
        {
            const int dummyLoadingNumber = -1;

            bool   allowed              = false;
            string errorMessage         = string.Empty;
            string drugBarcode          = string.Empty;

            try
            {
                // Get the drug barcode
                if (!mapper.ContainsKey(DATATAG_DRUGBARCODE))
                {
                    string error = string.Format(ERRORMSG_TEMPLATEMISSINGDATATAG, DATATAG_DRUGBARCODE);
                    throw new ApplicationException(error);
                }
                drugBarcode = mapper[DATATAG_DRUGBARCODE];

                // If this is the same as a previous message the send out the same reply (and end)
                if (this.lastReceivedMessageType.Equals(messageType, StringComparison.CurrentCultureIgnoreCase) && lastAskDrugReturnRight.IsMatchingMessage(dummyLoadingNumber, drugBarcode))
                {
                    // Reload the cached data
                    allowed = lastAskDrugReturnRight.replyAllowed;
                    errorMessage = lastAskDrugReturnRight.replyErrorMessage;
                }
                else
                {
                    // New message so query database again

                    // Clear existing drug info
                    lastAskDrugReturnRight.Clear();

                    // Get the product data
                    WProduct product = new WProduct();
                    product.LoadBySiteIDAndBarcode (SessionInfo.SiteID, drugBarcode);
                    if (!product.Any())
                    {
                        string error = string.Format(ERRORMSG_INVALIDBARCODE, drugBarcode);
                        throw new ApplicationException(error);
                    }

                    // Get if drug is valid for this location
                    if (product[0].Location != this.config.Location)
                    {
                        string error = string.Format(ERRORMSG_INVALIDLOCATION, product[0].Location);
                        throw new ApplicationException(error);
                    }

                    // All okay
                    allowed = true;
                }
            }
            catch (Exception ex)
            {
                errorMessage = AddMessageError(ex, messageID, dummyLoadingNumber, drugBarcode);
            }
            
            // Update cached reply
            lastAskDrugReturnRight.Set (dummyLoadingNumber, drugBarcode, allowed, false, errorMessage);

            // Send reply
            return ReplyDrugAllowedMsg(allowed, false, mapper, errorMessage);
        }

        /// <summary>
        /// Processes an new delivery message
        /// Submit the receipt of goods
        /// </summary>
        /// <param name="messageID">Message ID</param>
        /// <param name="mapper">Sections in the message</param>
        /// <returns>HL7 replay string</returns>
        public string ProcessNewDeliveryMsg(Guid messageID, Dictionary<string, string> mapper)
        {
            int loadingNumber = -1;
            string drugBarcode = string.Empty;

            try
            {
                // Get the loading number
                if (!mapper.ContainsKey(DATATAG_LOADINGNUMBER))
                {
                    string error = string.Format(ERRORMSG_TEMPLATEMISSINGDATATAG, DATATAG_LOADINGNUMBER);
                    throw new ApplicationException(error);
                }

                string loadingNumberStr = mapper[DATATAG_LOADINGNUMBER];
                if (!int.TryParse(loadingNumberStr, out loadingNumber))
                {
                    string error = string.Format(ERRORMSG_INVALIDDELIVERNUMBER, loadingNumberStr);
                    throw new ApplicationException(error);
                }

                // Get the drug barcode
                if (mapper.ContainsKey(DATATAG_DRUGBARCODE))
                    drugBarcode = mapper[DATATAG_DRUGBARCODE];

                // Get order loading
                OrderLoadingRow orderLoading = OrderLoading.GetBySiteAndLoadingNumber(SessionInfo.SiteID, loadingNumber);
                if (orderLoading == null)
                {
                    string error = string.Format(ERRORMSG_INVALIDDELIVERNUMBER, loadingNumber);
                    throw new ApplicationException(error);
                }

                // Get order
                WOrder orders = orderLoading.GetOrders(drugBarcode);
                if (!orders.Any())
                {
                    string error = string.Format(ERRORMSG_INVALIDBARCODE, drugBarcode, loadingNumber);
                    throw new ApplicationException(error);
                }

                // And process receipt
                using(ReceiptLineProcessor processor = new ReceiptLineProcessor())
                {
                using (WReconcil reconcil = new WReconcil())
                {
                    // Get the reconcil record linked to this loading (if any)
                    reconcil.RowLockingOption = LockingOption.HardLock;
                    reconcil.LoadOpenByLoadingNumberAndPrimaryBarcode(SessionInfo.SiteID, orderLoading.LoadingNumber, drugBarcode);

                    ReceiptLine receipt = new ReceiptLine();
                    receipt.NSVCode         = orders[0].NSVCode;
                    receipt.OrderNumber     = orders[0].OrderNumber;
                    receipt.QuantityInPacks = 1;
                    receipt.SiteNumber      = Sites.GetNumberBySiteID(orders[0].SiteID);
                    receipt.WReconcilID     = reconcil.Any() ? reconcil[0].WReconcilID : (int?)null;

                    // Normaly only add to orders that can be received on.
                    // However with Rowa if we have gone this far and no open orders left then it is too late to reject
                    // so to ignore any errors to do with closed or completd orderes
                    // This is a rare condition as it will normally be caught by the ProcessAskNewDeilverMsg.
                    receipt.AllowOverReceiving             = true;
                    receipt.AllowReceivingOnCompletedOrder = true;

                    // Lock all rows
                    processor.Lock(receipt);

                    // Update row process
                    using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                    {
                        processor.Update(receipt);

                        // Assoicate order loading with reconciliation
                        if (!reconcil.Any() || (reconcil[0].WReconcilID != receipt.WReconcilID))
                            OrderLoading.AssociateOrderLoadingWithReconcil(orderLoading.OrderLoadingID, receipt.WReconcilID.Value);

                        scope.Commit();
                    }
                }
                }
            }
            catch (Exception ex)
            {
                AddMessageError(ex, messageID, loadingNumber, string.Empty);
            }
            
            return ReplyItemTakenByITMsg(mapper);
        }

        /// <summary>Creates a new delivery reply message</summary>
        /// <param name="valid">If the new delivery is valie</param>
        /// <param name="mapper">data tag dictionary</param>
        /// <param name="errorMessage">Error message</param>
        /// <returns>HL7 delivery reply message</returns>
        public string ReplyNewDeliveryMsg(bool valid, Dictionary<string, string> mapper, string errorMessage)
        {
            mapper.Add("Error", errorMessage);
            if (valid)
                return decoder.GenerateReply(REPLY_NEWDELIVERVALID, mapper);
            else
                return decoder.GenerateReply(REPLY_NEWDELIVERINVALID, mapper);
        }

        /// <summary>Creates a new reply drug allowed message</summary>
        /// <param name="allowed">If drug input is allowed</param>
        /// <param name="missingLoadingNumber">If not allowed because of missing loading number</param>
        /// <param name="mapper">data tag dictionary</param>
        /// <param name="errorMessage">Error message</param>
        /// <returns>HL7 delivery reply message</returns>
        public string ReplyDrugAllowedMsg(bool allowed, bool missingLoadingNumber, Dictionary<string, string> mapper, string errorMessage)
        {
            mapper.Add("Error", errorMessage);
            mapper.Add("ErrorCode", missingLoadingNumber ? "B" : "X");
            if (allowed)
                return decoder.GenerateReply(REPLY_INPUTALLOWED, mapper);
            else
                return decoder.GenerateReply(REPLY_INPUTNOTALLOWED, mapper);
        }

        /// <summary>Reply for message that has been processed by interface</summary>
        /// <param name="mapper">data tag dictionary</param>
        /// <returns>HL7 delivery reply message</returns>
        public string ReplyItemTakenByITMsg(Dictionary<string, string> mapper)
        {
            return decoder.GenerateReply(REPLY_ITEMTAKENBYIT, mapper);
        }

        /// <summary>Always replies with drug info not found</summary>
        /// <param name="mapper">data tag dictionary</param>
        /// <returns>HL7 delivery reply message</returns>
        public string ReplyDrugInfo(Dictionary<string, string> mapper)
        {
            return decoder.GenerateReply(REPLY_DRUGINFONOTFOUND, mapper);
        }

        /// <summary>Replies with error message (the error is truncated to 150chars)</summary>
        /// <param name="mapper">data tag dictionary</param>
        /// <param name="error">error message</param>
        /// <returns>HL7 delivery reply message</returns>
        public string ReplyError(Dictionary<string, string> mapper, string error)
        {
            mapper["Error"] = error.SafeSubstring(0, 150);
            return decoder.GenerateReply(REPLY_ERROR, mapper);
        }

        /// <summary>Add an error message to the log</summary>
        /// <param name="ex">Exception</param>
        /// <param name="messageID">Message ID</param>
        /// <param name="loadingNumber">Loading number (or -1 if not present)</param>
        /// <param param name="barcode">barcode error</param>
        /// <returns>Error message</returns>
        private string AddMessageError(Exception ex, Guid messageID, int loadingNumber, string barcode)
        {
            // write to console
            System.Diagnostics.Debug.WriteLine(ex.Message);

            // Log application error
            log.LogError(config.SessionID, config.InterfaceComponentId, ex, 0, string.Empty, messageID);

            // If related to order loading the write to execption table
            if (loadingNumber != -1)
            {
                OrderLoadingException exceptions = new OrderLoadingException();
                exceptions.Add(loadingNumber, barcode, ex.Message);
                exceptions.Save();
            }

            return ex.Message;
        }
    }
}
