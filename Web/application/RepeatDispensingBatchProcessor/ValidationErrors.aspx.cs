using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using ascribe.pharmacy.shared;

public partial class application_RepeatDispensingBatchProcessor_ValidationErrors : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        lblBatchDescription.InnerHtml = "Batch description = " + Request.QueryString["Description"];
        //lblBatchID.InnerHtml = "BatchID " + Request.QueryString["BatchID"];
        int _SessionID = int.Parse(Request.QueryString["SessionID"]);
        GENRTL10.StateRead stateRead = new GENRTL10.StateRead();
        string errorXML = stateRead.SessionAttributeGet(_SessionID, "RepeatDispensingBatchValidationErrorXML");
        XDocument xdoc = XDocument.Parse(errorXML);
        List<ValidationError> errorList = (from error in xdoc.Descendants("ValidationError")
                                         select new ValidationError
                                         {
                                             ErrorMessage = error.Attribute("ErrorMessage") == null ? "" : error.Attribute("ErrorMessage").Value,
                                             Exception = error.Attribute("Exception") == null ? false : Convert.ToBoolean(int.Parse(error.Attribute("Exception").Value)),
                                             KeyName = error.Attribute("KeyName") == null ? "" : error.Attribute("KeyName").Value,
                                             KeyValue = error.Attribute("KeyValue") == null ? "" : error.Attribute("KeyValue").Value,
                                             PropertyName = error.Attribute("PropertyName") == null ? "" : error.Attribute("PropertyName").Value,
                                             ClassName = error.Attribute("ClassName") == null ? "" : error.Attribute("ClassName").Value,
                                             ErrorCode = error.Attribute("ErrorCode") == null ? 0 : int.Parse(error.Attribute("ErrorCode").Value),
                                         }).ToList<ValidationError>();
        rptData.DataSource = errorList;
        rptData.DataBind();

                                            

    
    
    }


}
