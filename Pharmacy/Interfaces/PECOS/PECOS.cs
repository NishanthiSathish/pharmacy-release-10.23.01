//===========================================================================
//
//							        PECOS.cs
//
//  This provides an interface engine reply component for Pharmacy PECOS Interface 
//  
//  The incoming message text should be in the form of the following example xml schema
//  "<pecosmessage><siteid>15</siteid><wardcode>AW1</wardcode><orderid>GBX001</orderid><linenumber></linenumber>
//  <nsvcode>DUX172G</nsvcode><quantity>3</quantity></pecosmessage>"
//
//  The interface will utilise the data from this to create Requisition (WRequis)
//  records at status 5 (Awaiting Picking Ticket Printing). It should also update
//  the associated product row by increasing the oustanding figure by the qty requested here so 
//  that this can be factored into procurement decsions (ordering)
//
//  The main process message call returns any error or validation message
//  The object also sets a has message failed flag 
//  
//
//	Modification History:
//	20Oct15 TH  Written
//  11Nov15 TH  Added check on inuse for ward
//  17Aug17 TH  switch factoring as PECOS now always to send us packs (TFS 191516)
//===========================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.basedatalayer;
using _Shared;
using System.Xml;

namespace ascribe.interfaces.replycomponents.pecosreplycomponent
{
    public class PECOS
    {

        #region Member variables
        //private Config _config;                    // Configuration info for UHB Sage Message Processor
        //private int _interfaceComponentId = -1; // Interface component ID
        private EIELogger _log;                       // Interface engine EIELogger 
        //private BaseRobot _robot = null;              // Robot class used to process the message
        protected Boolean hasmsgfailed; 

        #endregion


        
        
        

        /// <summary>
        /// Called when need to send a message reply
        /// </summary>
        /// <param name="messageID">message ID</param>
        /// <param name="messageText">message</param>
        /// <returns>reply message</returns>
        public string ProcessMessage(int SessionID, Guid messageID, string messageText, string instanceName, int InterfaceComponentId)
        {
            
            int intQuantityOrdered = 0;
            WProduct prod = new WProduct();
            WSupplier ward = new WSupplier();
            decimal decQuantityOrdered =0;
            //Boolean blnPrintinPacks = true; //This is now handled exclusively in the WRequis object

            if (InterfaceComponentId > 0)
                _log = new EIELogger(instanceName);

            //Message reply = null;
            string reply = null;
            try
            {
                //Decode Msg
                //char delimiterChar =  '|';
                //string[] pecosfields = messageText.Split(delimiterChar);

                //Now its xml !!!
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(messageText);

                XmlNode xnode = xmlDoc.SelectSingleNode("pecosmessage");

                string strSiteID = xnode["siteid"].InnerText;
                string strWardCode = xnode["wardcode"].InnerText;
                string strNSVCode = xnode["nsvcode"].InnerText;
                string strQuantity = xnode["quantity"].InnerText;
                string strOrderID = xnode["orderid"].InnerText;
                string strLineNumber = xnode["linenumber"].InnerText;
                

                bool MsgValid = true;
                string strValid = string.Empty;
                int intSite =0;

                bool result = Int32.TryParse(strSiteID, out intSite);
                if (!result && intSite > 0)
                {
                    MsgValid = false;
                    strValid = "No Valid Site Number Supplied";
                }
                else
                {
                    result = Int32.TryParse(strQuantity, out intQuantityOrdered);
                    if (!result && intQuantityOrdered > 0)
                    {
                        MsgValid = false;
                        strValid = "Quantity required is not valid";
                    }
                    if ((intQuantityOrdered < 1) && MsgValid)
                    {
                        MsgValid = false;
                        strValid = "Quantity Ordered must be at least one issue unit";
                    }
                }

                // Initalise the pharmacy data layer session information
                SessionInfo.InitialiseSessionAndSiteID(SessionID, intSite);

                if (MsgValid)
                {
                    //Validate the drug  code
                    prod.LoadByProductAndSiteID(strNSVCode, intSite);
                    if (prod.Count != 1)
                    {
                        MsgValid = false;
                        strValid = "Product cannot be found";
                    }
                }

                if (MsgValid)
                {
                    //Validate the ward code
                    ward.LoadByCodeAndSiteID(strWardCode, intSite);
                    if (ward.Count != 1)
                    {
                        MsgValid = false;
                        strValid = "Ward Cannot be Found";
                    }
                    else if (ward[0].InUse == false)
                    {
                        MsgValid = false;
                        strValid = "Ward Not in Use";
                    }
                }

                if (!MsgValid)
                {
                    //_log.LogError(SessionID, InterfaceComponentId, ex, 0, string.Empty, messageID);
                    reply = "Order " + strOrderID + " , Line Number " + strLineNumber + " : " + strValid;
                    hasmsgfailed = true;
                }
                else
                {
                    //First we must to Convert to packs if needed - 07Oct15 NO ! Always convert to packs !
                    //WConfiguration config = new WConfiguration();
                    //config.LoadBySiteCategorySectionAndKey(intSite, "D|WorkingDefaults", "", "PrintinPacks");
                    //if (config.Count == 1)
                    //{
                    //    if (config[0].Value != "-1")
                    //        blnPrintinPacks = false;
                    //}

                    //if (blnPrintinPacks)
                    //{
                        //17Aug17 TH Replaced with below as PECOS now always to send us packs (TFS 191516)
                        //decQuantityOrdered = decimal.Divide(intQuantityOrdered, prod[0].ConversionFactorPackToIssueUnits);
                        
                    //}
                    //else
                    //{
                    //17Aug17 TH Replaced above as PECOS now always to send us packs (TFS 191516)
                        decQuantityOrdered = (decimal)intQuantityOrdered;
                    //}

                    //We are going to try and create a new Requisition and save
                    WRequis req = new WRequis();
                    //req.Add(
                    WRequisRow reqrow = req.Add();
                    reqrow.SiteID = intSite;
                    reqrow.Status = OrderStatusType.Five;
                    reqrow.VATCode = prod[0].VATCode;
                    reqrow.SupplierCode = strWardCode;
                    reqrow.SupplierType = SupplierType.Ward; 
                    reqrow.NSVCode = strNSVCode;
                    reqrow.Location = prod[0].Location;
                    reqrow.OutstandingInPacks = decQuantityOrdered;
                    reqrow.CreatedUser = SessionInfo.UserInitials;
                    reqrow.CustOrdNo = "";
                    reqrow.DateTimeOrdered = DateTime.Now;
                    reqrow.NumPrefix = "";
                    reqrow.OrderNumber = 0;
                    reqrow.PickNumber = 0;
                    reqrow.RequisitionNumber = "";
                    reqrow.DLOWard = "";
                    reqrow.DLO = false;
                    
                    
                    //We also need to update the qty outstanding

                    ProductStock stock = new ProductStock();
                    //ProductStockRow stockrow = new ProductStockRow();
                    stock.RowLockingOption = LockingOption.HardLock;
                    try
                    {

                        stock.LoadBySiteIDAndNSVCode(strNSVCode, intSite);

                        //if (stock.Count == 0)

                        //throw new ApplicationException(string.Format("Failed to update product note as db does not exist (NSVCode:{0} site ID:{1})", NSVCode, siteID));

                        //stock[0].OutstandingInIssueUnits = (stock[0].OutstandingInIssueUnits + intQuantityOrdered);
                        //OutstandingInIssueUnits is not quite what it says on the tin. Needs addressing more widely later (TFS 135099)
                        stock[0].OutstandingInIssueUnits = (stock[0].OutstandingInIssueUnits + decimal.ToDouble(decQuantityOrdered));

                        using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                        {
                            stock.Save();
                            req.Save();
                            trans.Commit();
                        }
                    }
                    finally
                    {
                        // Release locks
                        stock.Dispose();
                    }

                }

            }
            catch (Exception ex)
            {
                // If error log to interface engine tables
                if (InterfaceComponentId > 0)
                        _log.LogError(SessionID, InterfaceComponentId, ex, 0, string.Empty, messageID);

                reply = ex.ToString();
                hasmsgfailed = true;

            }

            return reply;
        }

        public bool HasMessageErrored
        {
            get { return hasmsgfailed; }
        }

    }        
}
