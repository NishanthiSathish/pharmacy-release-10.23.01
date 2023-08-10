using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using System.Text;
using ChartSchema;
using System.Data;


namespace Ascribe.ICW
{
    /// <summary>
    /// Class file for the ResultsViewerLoader ashx handler page within
    /// the Results Viewer application
    /// </summary>
    public class ResultsViewerLoader : IHttpHandler
    {
        private const string CONTENTTYPE_TEXT_XML = "text/xml";
        private const string CONTENTTYPE_TEXT_PLAIN = "text/plain";
        private const string GRID_SORT_ASC = "asc";
        private const string GRID_SORT_DESC = "desc";

        private int sessionId;

        /// <summary>Holds whether or not the current user is allowed to perform actions on the results in the resukt viewer.</summary>
        private bool resultsViewerActionsAllowed;

        private HttpContext context;
        private string[] statusNoteFilter = null;
        private StatusNoteFilterAction? statusNoteFilterAction = null;

        /// <summary>
        /// Represents ascending or descending sorting
        /// </summary>
        private enum GridSort
        {
            DESC, ASC
        }

        /// <summary>
        /// Desktop parameter filter actions
        /// </summary>
        private enum StatusNoteFilterAction
        {
            INCLUDE, EXCLUDE
        }

        public void ProcessRequest(HttpContext httpContext)
        {
            context = httpContext;

            // begin by extracting the session id from the querystring:
            ExtractSessionIdFromQuerystring();

            // Get whether or not the current user is allowed to perform actions on the results
            resultsViewerActionsAllowed = Ascribe.Common.Security.SessionHasPolicy(this.sessionId, "Results Viewer Actions");

            context.Response.ContentType = CONTENTTYPE_TEXT_PLAIN;

            string data = "";

            switch (context.Request.QueryString["method"].ToUpper())
            {
                case "GETRESULTSFORCATEGORY":
                    data = GetResultsForCategory();
                    break;
                case "GETTYPESFORTREE":
                    data = GetTypesForTree();
                    break;
                case "GETPATIENTIDFOREPISODE":
                    data = GetPatientIdForEpisode().ToString();
                    break;
                case "CREATEQUICKSEARCH":
                    data = CreateQuickSearch();
                    break;
                case "DELETEQUICKSEARCH":
                    data = DeleteQuickSearch();
                    break;
                case "UPDATEQUICKSEARCH":
                    data = UpdateQuickSearch();
                    break;
                case "GETPATIENTDETAILSFORGRIDHEADER":              //F0067381 PCannavan -  Populate Grid header with patient details
                    data = GetPatientDetailsForGridHeader();
                    break;
                case "GETMAXPREVIOUSDAYS":                          //F0067381 PCannavan - Retrieve setting values to define 'for the previous' filter field
                    data = GetMaxPreviousDays();
                    break;
                case "GETPENDINGSTRING":                          //F0067381 PCannavan - Retrieve setting value for Pending Result Text
                    data = GetPendingString();
                    break;
                case "GETDEFAULTSINGLEPATIENTDISPLAYMODE":
                    data = GetDefaultSinglePatientDisplayMode();
                    break;
                case "GETDEFAULTMULTIPATIENTDISPLAYMODE":
                    data = GetDefaultMultiPatientDisplayMode();
                    break;
                default:
                    data = "test";

                    break;
            }

            context.Response.Write(data);
        }

        private string InitialiseSearch()
        {
            return DoFullSearch(this.context) ? this.GetFullSearch() : this.GetTypesForTree();
        }

        private string GetTypesForTree()
        {
            //if(DoFullSearch(this.context))
            //{
            //    return this.GetFullSearch();
            //}

            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objFilter = new PRVRTL10.ResultFilter();

            PopulateFilterData(ref objFilter);

            string strXML = objResultRead.GetTypesForCatalogueTree(sessionId, objFilter);

            return BuildTreeFromXML(strXML, IsSinglePatient(objFilter.PatientId.ToString()));
        }

        private string GetFullSearch()
        {
            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();

            ExtractActionDesktopParams();

            PopulateFilterData(ref objResultFilter);

            string resultsXML = objResultRead.GetResultsByDate(sessionId, objResultFilter, null);

            XElement data = XElement.Parse(resultsXML);
            StringBuilder htmlGrid = new StringBuilder();
            IEnumerable<XElement> headers = data.Descendants("responseHeader");
            IEnumerable<XElement> resultItems = data.Descendants("resultItems");
            IEnumerable<XElement> actionHeaders = data.Descendants("actionHeader");
            XElement response = data.Element("response");

            bool singlePatient = IsSinglePatient(context.Request.QueryString["patientId"]);
            string headerClass = "headerRowMULTIPATIENT";
            string gridClass = "gridBodyMULTIPATIENT";

            //F0067381 PCannavan - styling added dependent upon patient mode due to changes made for viewing scrollable data in multi patient tables
            if (singlePatient)
            {
                headerClass = "headerRowSINGLEPATIENT";
                gridClass = "gridBodySINGLEPATIENT resultsByDate";
            }
            else
            {
                headerClass = "headerRowMULTIPATIENT";
                gridClass = "gridBodyMULTIPATIENT resultsByDate";
            }

            // possible that no result data will come back from this type of request
            // and this needs to be checked:
            if (resultItems != null && resultItems.Count() > 0)
            {
                htmlGrid.Append("<table cellpadding='0' cellspacing='0' class='tabularData'>");
                htmlGrid.Append("<thead class=\"" + headerClass + "\">");
                htmlGrid.Append(ConstructGridHeadersForDate(response, singlePatient, actionHeaders));
                htmlGrid.Append("</thead>");
                htmlGrid.Append("<tbody class=\"" + gridClass + "\">");
                foreach (var item in resultItems)
                {
                    if (singlePatient)
                    {
                        htmlGrid.Append("<tr>");
                    }
                    else
                    {
                        htmlGrid.Append("<tr class='MULTIPATIENTRow'>");
                    }

                    htmlGrid.Append(ConstructGridBodyByDate(headers, actionHeaders, item, singlePatient, true));
                    htmlGrid.Append("</tr>");
                }

                htmlGrid.Append("<tbody>");
                htmlGrid.Append("</table>");
            }
            else
            {
                htmlGrid.Append("<div class=\"noDataForResult\">No data was found for this search</div>");
            }

            return htmlGrid.ToString();
        }

        private bool IsSinglePatient(string patientId)
        {
            return !String.IsNullOrEmpty(patientId) && patientId != "-1";
        }

        private string BuildTreeFromXML(string typeXML, bool singlePatient)
        {
            XElement data = XElement.Parse(typeXML);

            if (data.Descendants("Item").Count() == 0)
                return "";

            StringBuilder htmlTree = new StringBuilder();

            htmlTree.Append("<div id=\"rvTreeContainer\">");
            //F0077211 PCannavan - Additional container div to maintain tree formatting when the panel is resized
            htmlTree.Append("<div id=\"rvTreeSubContainer\">");
            htmlTree.Append("<ul id=\"catalogTree\">");
            htmlTree.Append("<li><span id=\"root\" class=\"spanContainer hasNodes\">");
            if (singlePatient)
                htmlTree.Append("<input type=\"checkbox\" />");
            htmlTree.Append("<label>All categories<span>&nbsp;</span></label></span><ul>");

            // pull all of the items from the xml into a collection:
            IEnumerable<XElement> nodes = data.Descendants("Item");

            int index = 0;
            htmlTree.Append(BuildNodesForParent(nodes, "0", singlePatient, ref index));

            htmlTree.Append("</ul></li>");
            htmlTree.Append("</ul>");
            htmlTree.Append("</div>");
            htmlTree.Append("</div>");

            return htmlTree.ToString();
        }

        /// <summary>
        /// TBC
        /// </summary>
        /// <param name="nodes"></param>
        /// <param name="parentId"></param>
        /// <returns></returns>
        private string BuildNodesForParent(IEnumerable<XElement> nodes, string parentId, bool singlePatient, ref int index)
        {
            StringBuilder html = new StringBuilder();
            int i = 0;
            bool bNodeHasChildren = false;
            string itemDescription = string.Empty;
            string itemCount = string.Empty;

            foreach (XElement node in nodes)
            {
                bNodeHasChildren = false; // reset!
                itemDescription = node.Attribute("Description").Value;
                itemCount = node.Attribute("RequestCount").Value;

                if (node.Attribute("ParentID").Value == parentId)
                {
                    bNodeHasChildren = NodeHasChildren(nodes, node.Attribute("ID").Value);

                    // build the individual list item:
                    html.Append("<li title=\"" + itemDescription + " (" + itemCount + ")\"><span id=\"" + node.Attribute("ID").Value + "\" data-index=\"" + index + "\" class=\"");
                    index++;
                    if (bNodeHasChildren)
                    {
                        html.Append("spanContainer hasNodes\">");
                    }
                    else
                    {
                        html.Append("spanContainer\">");
                    }

                    if (singlePatient)
                        html.Append("<input type=\"checkbox\" />");

                    html.Append("<label>" + itemDescription + "<span>(" + itemCount + ")</span>" +
                        "</label></span>");

                    // before we close off the list item, check to see if this node
                    // has child nodes:
                    if (bNodeHasChildren)
                        html.Append("<ul>");

                    // recursively call this method and inject any list items in between the ul:
                    html.Append(BuildNodesForParent(nodes, node.Attribute("ID").Value, singlePatient, ref index));

                    // close off the ul if applicable:
                    if (bNodeHasChildren)
                        html.Append("</ul>");

                    // close
                    html.Append("</li>");
                }
            }

            return html.ToString();
        }

        private bool NodeHasChildren(IEnumerable<XElement> nodes, string parentId)
        {
            foreach (XElement node in nodes)
            {
                if (node.Attribute("ParentID").Value == parentId)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Get the id for the patient that belongs to the episode
        /// </summary>
        /// <returns></returns>
        private string GetPatientIdForEpisode()
        {
            int episodeId = int.Parse(context.Request.QueryString["episodeId"]);
            int patientId = -1;
            string patientDescription = "";

            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();

            objResultRead.GetPatientIdAndDescriptionForEpisode(sessionId, episodeId, ref patientId, ref patientDescription);

            return patientId.ToString() + "|" + patientDescription;
        }

        /// <summary>
        /// Pulls in filters on the type of notes allowed (i.e. the action columns with checkboxes)
        /// </summary>
        private void ExtractActionDesktopParams()
        {
            string statusNoteFilterCsv = context.Request.QueryString["statusNoteFilter"];
            if (!String.IsNullOrEmpty(statusNoteFilterCsv))
                statusNoteFilter = statusNoteFilterCsv.Split(',');
            string action = context.Request.QueryString["statusNoteFilterAction"];
            if (action != null && action.ToLower().Equals("include"))
                statusNoteFilterAction = StatusNoteFilterAction.INCLUDE;
            else
                statusNoteFilterAction = StatusNoteFilterAction.EXCLUDE;
        }

        /// <summary>
        /// Returns patient details to be displayed on the grid page to identify the current
        /// patient that is in context during single patient mode
        /// </summary>
        /// <returns></returns>
        private string GetPatientDetailsForGridHeader()
        {
            // F0067381 05.03.10 PCannavan - Include Primary and Secondary Patient Identifiers to Result Grid Patient Details
            string patientXML = string.Empty;

            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();

            PopulateFilterData(ref objResultFilter);
            patientXML = objResultRead.GetPatientDetailsForGridHeader(sessionId, objResultFilter);

            XElement data = XElement.Parse(patientXML);
            XElement row = data.Element("row");
            string headerStr = string.Empty;

            string surname = row.Attribute("surname") == null ? string.Empty : row.Attribute("surname").Value.ToUpper();
            string forename = row.Attribute("forename") == null ? string.Empty : row.Attribute("forename").Value;
            if (!string.IsNullOrEmpty(forename) && forename.Length > 1)
            {
                forename = forename.ToUpper()[0] + forename.ToLower().Substring(1);
            }

            string dob = row.Attribute("dob") == null ? string.Empty : Convert.ToDateTime(row.Attribute("dob").Value).ToShortDateString();
            string nhsNumber = row.Attribute("primaryPatientIdent") == null ? string.Empty : row.Attribute("primaryPatientIdent").Value;
            string hospitalNumber = string.Empty;
            foreach (XElement elem in data.Elements())
            {
                if (elem.Attribute("secondaryPatientIdentDesc") != null)
                {
                    if (elem.Attribute("secondaryPatientIdentDesc").Value.ToLower() == "hospital number")
                    {
                        if (elem.Attribute("secondaryPatientIdent") != null)
                        {
                            hospitalNumber = elem.Attribute("secondaryPatientIdent").Value;
                            break;
                        }
                    }
                }
            }

            headerStr = string.Format(@"<table class='patientDetailsBanner'>
    <tr>
        <td style='padding-right:10px;'>Name: <b>{0} {1}</b></td>
        <td style='padding-right:10px;'>DOB: <b>{2}</b></td>
        <td style='padding-right:10px;'>Hospital Number: <b>{4}</b></td>
        <td style='padding-right:10px;'>NHS Number: <b>{3}</b></td>
    </table>", surname, forename, dob, nhsNumber, hospitalNumber);

            return headerStr;
        }

        /// <summary>
        /// Returns patient details to be displayed on the chart page to identify the current
        /// patient that is in context during single patient mode
        /// </summary>
        /// <param name="page">The web page</param>
        /// <param name="httpContext">The context</param>
        /// <returns>Html for header</returns>
        public static string GetPatientDetailsForChartHeader(System.Web.UI.Page page, HttpContext httpContext)
        {
            // F0067381 05.03.10 PCannavan - Include Primary and Secondary Patient Identifiers to Result Grid Patient Details
            string patientXML = string.Empty;

            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();

            PopulateFilterData(httpContext, ref objResultFilter);
            int sessionId = int.Parse(httpContext.Request.QueryString["sessionId"]);
            patientXML = objResultRead.GetPatientDetailsForGridHeader(sessionId, objResultFilter);

            XElement data = XElement.Parse(patientXML);
            XElement row = data.Element("row");
            string headerStr = string.Empty;

            string surname = row.Attribute("surname") == null ? string.Empty : row.Attribute("surname").Value.ToUpper();
            string forename = row.Attribute("forename") == null ? string.Empty : row.Attribute("forename").Value;
            if (!string.IsNullOrEmpty(forename) && forename.Length > 1)
            {
                forename = forename.ToUpper()[0] + forename.ToLower().Substring(1);
            }

            string gender = row.Attribute("gender") == null ? string.Empty : row.Attribute("gender").Value;
            string strImage = string.Empty;
            if (gender.ToLower() == "female")
            {
                strImage = "PatientF.gif";
            }
            else
            {
                strImage = "PatientM.gif";
            }

            string imgUrl = string.Empty;
            string v10Location = System.Configuration.ConfigurationManager.AppSettings["ICW_V10Location"];

            imgUrl = (v10Location.EndsWith("/") ? v10Location : v10Location + "/") + "images/touchscreen/DrugAdministration/" + strImage;

            string dob = row.Attribute("dob") == null ? string.Empty : Convert.ToDateTime(row.Attribute("dob").Value).ToShortDateString();
            string nhsNumber = row.Attribute("primaryPatientIdent") == null ? string.Empty : row.Attribute("primaryPatientIdent").Value;
            string hospitalNumber = string.Empty;
            foreach (XElement elem in data.Elements())
            {
                if (elem.Attribute("secondaryPatientIdentDesc") != null)
                {
                    if (elem.Attribute("secondaryPatientIdentDesc").Value.ToLower() == "hospital number")
                    {
                        if (elem.Attribute("secondaryPatientIdent") != null)
                        {
                            hospitalNumber = elem.Attribute("secondaryPatientIdent").Value;
                            break;
                        }
                    }
                }
            }

            headerStr = string.Format(@"<table cellpadding='5' border='0' cellspacing='0' style='font-size:13pt; font-weight:strong;'>
    <tr>
        <td style='width:40px'><img style='height:32px;width:32px;' src='{5}' /></td>
        <td align='left' style='padding-right:10px;'>Name: <b>{0} {1}</b></td>
        <td align='left' style='padding-right:10px;'>Hospital Number: <b>{4}</b></td>
        <td align='left' style='padding-right:10px;'>NHS Number: <b>{3}</b></td>
        <td align='left' style='padding-right:10px;'>DOB: <b>{2}</b></td>
    </table>", surname, forename, dob, nhsNumber, hospitalNumber, imgUrl);

            return headerStr;
        }

        private string GetPatientDetailsFromElement(XElement element)
        {
            var html = new StringBuilder();
            html.Append(element.Attribute("patientName") == null ? string.Empty : element.Attribute("patientName").Value);
            html.Append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
            html.Append(element.Attribute("primaryPatientIdentDesc") == null ? string.Empty : element.Attribute("primaryPatientIdentDesc").Value);
            html.Append(": ");
            html.Append(element.Attribute("primaryPatientIdent") == null ? string.Empty : element.Attribute("primaryPatientIdent").Value);
            html.Append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
            html.Append(element.Attribute("secondaryPatientIdentDesc") == null ? string.Empty : element.Attribute("secondaryPatientIdentDesc").Value);
            html.Append(": ");
            html.Append(element.Attribute("secondaryPatientIdent") == null ? string.Empty : element.Attribute("secondaryPatientIdent").Value);

            return html.ToString();
        }

        private string GetResultsForCategoryByDate()
        {
            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();

            ExtractActionDesktopParams();

            PopulateFilterData(ref objResultFilter);

            string catId = context.Request.QueryString["catId"];

            string resultsXML = objResultRead.GetResultsByDate(sessionId, objResultFilter, catId);

            XElement data = XElement.Parse(resultsXML);
            StringBuilder htmlGrid = new StringBuilder();
            IEnumerable<XElement> headers = data.Descendants("responseHeader");
            IEnumerable<XElement> resultItems = data.Descendants("resultItems");
            IEnumerable<XElement> actionHeaders = data.Descendants("actionHeader");
            XElement response = data.Element("response");

            bool singlePatient = IsSinglePatient(context.Request.QueryString["patientId"]);
            string headerClass = "headerRowMULTIPATIENT";
            string gridClass = "gridBodyMULTIPATIENT";

            //F0067381 PCannavan - styling added dependent upon patient mode due to changes made for viewing scrollable data in multi patient tables
            if (singlePatient)
            {
                headerClass = "headerRowSINGLEPATIENT";
                gridClass = "gridBodySINGLEPATIENT resultsByDate";
            }
            else
            {
                headerClass = "headerRowMULTIPATIENT";
                gridClass = "gridBodyMULTIPATIENT resultsByDate";
            }

            // possible that no result data will come back from this type of request
            // and this needs to be checked:
            if (resultItems != null && resultItems.Count() > 0)
            {
                htmlGrid.Append("<table cellpadding='0' cellspacing='0' class='tabularData'>");
                htmlGrid.Append("<thead class=\"" + headerClass + "\">");
                htmlGrid.Append(ConstructGridHeadersForDate(response, singlePatient, actionHeaders));
                htmlGrid.Append("</thead>");
                htmlGrid.Append("<tbody class=\"" + gridClass + "\">");
                foreach (var item in resultItems)
                {
                    htmlGrid.Append(ConstructGridBodyByDate(headers, actionHeaders, item, singlePatient, true));
                    //htmlGrid.Append("</tr>");
                }

                htmlGrid.Append("<tbody>");
                htmlGrid.Append("</table>");
            }
            else
            {
                htmlGrid.Append("<div class=\"noDataForResult\">No data was found for this search</div>");
            }

            return htmlGrid.ToString();
        }

        private string GetResultsForCategoryByType()
        {
            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();

            ExtractActionDesktopParams();

            PopulateFilterData(ref objResultFilter);

            string sortBy = context.Request.QueryString["sortBy"];
            string sortDir = context.Request.QueryString["sortDir"];
            string catId = context.Request.QueryString["catId"];

            string resultsXML = objResultRead.GetResultsForType(sessionId, objResultFilter, catId, sortBy, sortDir);

            XElement data = XElement.Parse(resultsXML);
            StringBuilder htmlGrid = new StringBuilder();
            IEnumerable<XElement> headers = data.Descendants("responseHeader");
            IEnumerable<XElement> resultItems = data.Descendants("resultItems");
            IEnumerable<XElement> actionHeaders = data.Descendants("actionHeader");
            XElement response = data.Element("response");

            bool singlePatient = IsSinglePatient(context.Request.QueryString["patientId"]);
            bool isDiscrete = !this.IsTextualResult(resultItems);
            bool typeDescColumnRequired = Boolean.Parse(data.Element("response").Attribute("includeTypeDesc").Value);
            string categoryId = response.Attribute("id").Value;

            // possible that no result data will come back from this type of request
            // and this needs to be checked:
            if (resultItems != null && resultItems.Count() > 0)
            {
                //F0067381 PCannavan - headerClass and gridClass added to perform styling dependent upon patient mode
                htmlGrid.Append(ConstructGridBody(headers, actionHeaders, resultItems, categoryId, singlePatient, typeDescColumnRequired, response, isDiscrete));
            }
            else
            {
                // AKnox 11/06/09
                // Fix prevents a grid table with just the headers visible when no data comes back
                // for the requested request type
                htmlGrid.Append("<div class=\"noDataForResult\">No data was found for this type of result</div>");
            }

            return htmlGrid.ToString();
        }

        private string AddTypeTable(XElement response, XElement resultItem, IEnumerable<XElement> headers, IEnumerable<XElement> actionHeaders, bool singlePatient, bool typeDescColumnRequired, bool isDiscrete)
        {
            string headerClass;
            string gridClass;

            if (singlePatient)
            {
                headerClass = "headerRowSINGLEPATIENT";
                gridClass = "gridBodySINGLEPATIENT";
            }
            else
            {
                headerClass = "headerRowMULTIPATIENT";
                gridClass = "gridBodyMULTIPATIENT";
            }

            var table = new StringBuilder();
            table.Append("<table cellpadding='0' cellspacing='0' class='tabularData'>");

            table.Append("<thead class=\"" + headerClass + "\">");
            table.Append("<tr>");
            table.Append(ConstructGridHeaders(response, resultItem, headers, actionHeaders, singlePatient, typeDescColumnRequired, isDiscrete));
            table.Append("</tr>");
            table.Append("</thead>");

            table.Append("<tbody class=\"" + gridClass + "\">");

            return table.ToString();
        }

        private string CloseTable()
        {
            return "</tbody></table>";
        }

        /// <summary>
        /// Brings back a group of results in xml format for a particular type
        /// of request/modality
        /// </summary>
        /// <returns></returns>
        private string GetResultsForCategory()
        {
            switch (context.Request.QueryString["displayMode"])
            {
                case "date":
                    return this.GetResultsForCategoryByDate();

                default:
                    return this.GetResultsForCategoryByType();
            }
        }

        /// <summary>
        /// Returns whether or not the result is textual
        /// </summary>
        /// <param name="resultItems">The result items to search</param>
        /// <returns>True if textual</returns>
        private bool IsTextualResult(IEnumerable<XElement> resultItems)
        {
            IEnumerable<XElement> results = resultItems.Descendants("result");
            double num = 0;
            foreach (XElement element in results)
            {
                if (element.Attribute("rangerUpper") == null
                    || element.Attribute("rangerLower") == null
                    || string.IsNullOrEmpty(element.Attribute("rangerUpper").Value)
                    || !double.TryParse(element.Attribute("rangerUpper").Value, out num)
                    || string.IsNullOrEmpty(element.Attribute("rangerLower").Value)
                    || !double.TryParse(element.Attribute("rangerLower").Value, out num))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Brings back a group of results in xml format for a particular type
        /// of request/modality
        /// </summary>
        /// <param name="context">The context of the web request</param>
        /// <returns>Charting object</returns>
        public static Charting GetChartingResultGroupedByHighLow(HttpContext context)
        {
            Charting charting = new Charting();
            PRVRTL10.ResultRead objResultRead = new PRVRTL10.ResultRead();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();

            // Get the filter from the contexts querystring
            PopulateFilterData(context, ref objResultFilter);

            // Get session id and cat ids
            int sessionId = int.Parse(context.Request.QueryString["sessionId"]);
            string[] responseTypeIds = context.Request.QueryString["responseTypeIds"].Split(',');

            DataTable dataTable = new DataTable();
            // loop through each category
            foreach (string responseTypeId in responseTypeIds)
            {
                // Get data for current category
                DataTable typeDataTable = objResultRead.GetDataTableForType(sessionId, objResultFilter, responseTypeId);

                // Add the category's data to the main dataTable
                dataTable.Merge(typeDataTable);
            }

            // Remove non-numeric data as we cant chart non-numeric data
            // 67689 CD Remove deleted data
            var dataToUse = dataTable.AsEnumerable().Where(a => Convert.ToString(a["ResultDeleted"]) == "0" && Convert.ToString(a["lowValue"]) != string.Empty && Convert.ToString(a["highValue"]) != string.Empty);
            if (dataToUse.Any())
            {
                dataTable = dataToUse.CopyToDataTable();
            }
            else
            {
                dataTable.Rows.Clear();
            }

            if (dataTable.Rows.Count > 0)
            {
                // determine whether or not we only need 1 chart or multiple charts.
                int totalNumberOfComponents = (from DataRow r in dataTable.Rows select new { col1 = r["responseTypeID"], col2 = r["Category"] }).Distinct().Count();
                bool requireMutipleCharts = false;
                if (totalNumberOfComponents > 3)
                {
                    requireMutipleCharts = true;
                }
                else
                {
                    // We need to determine whether the data can all be placed in a single chart or whether it needs to be spread over multiple charts.
                    // This is done by getting the range of the first item from the dataTable and comparing it to the other items in the dataTable.
                    // If their range is outside the thresholds as defined by "ChartRangePercentage" and "ChartValuePercentage" then we need more than 1 graph

                    double rangePercentage = Convert.ToDouble(new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "ResultsViewer", "ChartRangePercentage", "0.4"));
                    double valuePercentage = Convert.ToDouble(new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "ResultsViewer", "ChartValuePercentage", "0.4"));

                    // Get the first min/max value
                    var highLow = (from DataRow r in dataTable.Rows orderby r["responseTypeID"] select new { lowValue = Convert.ToDouble(r["lowValue"]), highValue = Convert.ToDouble(r["highValue"]) }).First();

                    // Get the ranges to be used when retrieving data that is close to the highLow
                    double range = highLow.highValue - highLow.lowValue;

                    // Get all rows that fall within the range of the first highlow
                    DataTable currentHighLowDataTable = (from DataRow r in dataTable.Rows
                                                         where (Convert.ToDouble(r["highValue"]) - Convert.ToDouble(r["lowValue"])) >= (range - (range * rangePercentage))
                                                         && (Convert.ToDouble(r["highValue"]) - Convert.ToDouble(r["lowValue"])) <= (range + (range * rangePercentage))
                                                         && (Convert.ToDouble(r["highValue"]) >= (highLow.highValue - (highLow.highValue * valuePercentage)))
                                                         && (Convert.ToDouble(r["highValue"]) <= (highLow.highValue + (highLow.highValue * valuePercentage)))
                                                         select r).CopyToDataTable();

                    if (dataTable.Rows.Count > currentHighLowDataTable.Rows.Count)
                    {
                        requireMutipleCharts = true;
                    }
                }

                if (requireMutipleCharts)
                {
                    return GetMutipleCharts(context, dataTable);
                }
                else
                {
                    return GetSingleChart(context, dataTable);
                }
            }
            else
            {
                // No numeric data to chart!!!
                return null;
            }
        }

        /// <summary>
        /// Gets a single chart for the data
        /// </summary>
        /// <param name="context">The context of the web</param>
        /// <param name="dataTable">The datatbale with the data</param>
        /// <returns>A single chart</returns>
        private static Charting GetSingleChart(HttpContext context, DataTable dataTable)
        {
            Charting charting = new Charting();
            int sessionId = int.Parse(context.Request.QueryString["sessionId"]);
            double rangePercentage = Convert.ToDouble(new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "ResultsViewer", "ChartRangePercentage", "0.4"));
            double valuePercentage = Convert.ToDouble(new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "ResultsViewer", "ChartValuePercentage", "0.4"));

            // Holds the mindate and max date of all data
            var totalMinDate = Convert.ToDateTime((from DataRow r in dataTable.Rows orderby Convert.ToDateTime(r["dateFrom"]) ascending select r).First()["dateFrom"]);
            var totalMaxDate = Convert.ToDateTime((from DataRow r in dataTable.Rows orderby Convert.ToDateTime(r["dateFrom"]) descending select r).First()["dateFrom"]);

            // Get the buffer used to padd the charts so that a high/low line can be created
            TimeSpan span = totalMaxDate - totalMinDate;
            int buffer = (int)((double)span.TotalDays * 0.1);
            if (buffer == 0)
            {
                buffer = 1;
            }

            while (dataTable.Rows.Count > 0)
            {
                // Create a new chart
                ChartType chart = new ChartType();
                chart.BackColour = new ColourType("#EEEEEE");

                // Create a new chart area for ther chart
                ChartAreaType chartArea = new ChartAreaType("ChartArea");
                chartArea.BackColour = new ColourType("#FBE8E4"); // default back colour is light pink
                chart.ChartAreas.Add(chartArea);

                // Add legend to chart
                LegendType legend = new LegendType()
                {
                    Name = "MainLegend",
                    Title = string.Empty,
                    DockingSpecified = true,
                    Docking = ChartSchema.DockingTypes.Top,
                    LegendStyleSpecified = true,
                    LegendStyle = ChartSchema.LegendStyleTypes.Row
                };
                chart.AddLegend(legend);

                // Setup up axis styles for chart area
                chartArea.AxisY = new AxisType() { IsMarginVisibleSpecified = true, IsMarginVisible = false };
                chartArea.AxisY.MajorGrid = new GridType();
                chartArea.AxisY.MajorGrid.LineColour = new ColourType("#cccccc");
                chartArea.AxisY.MinorGrid = new GridType() { Enabled = false };
                chartArea.AxisX = new AxisType() { IsMarginVisibleSpecified = true, IsMarginVisible = false };
                chartArea.AxisX.MajorGrid = new GridType();
                chartArea.AxisX.MajorGrid.LineColour = new ColourType("#cccccc");
                chartArea.AxisX.MinorGrid = new GridType() { Enabled = false };

                // setup x axis range
                chartArea.AxisX.MinimumSpecified = true;
                chartArea.AxisX.Minimum = totalMinDate.Date.AddDays(-buffer).ToOADate();
                chartArea.AxisX.MaximumSpecified = true;
                chartArea.AxisX.Maximum = totalMaxDate.Date.AddDays(buffer).ToOADate();

                // Get all the different response/category types and sort by category, responseTypeID
                var responseCategoryTypes = (from DataRow r in dataTable.Rows orderby r["responseTypeID"] select new { ResponseTypeId = Convert.ToInt32(r["responseTypeID"]), ResponseTypeDesc = Convert.ToString(r["responseTypeDescription"]), Category = Convert.ToString(r["Category"]) }).OrderBy(r => r.Category).ThenBy(r => r.ResponseTypeId).Distinct();
                bool singleChart = false;
                if (responseCategoryTypes.Count() == 1)
                {
                    // only one series, we can add high/low
                    singleChart = true;
                }
                else
                {
                    // override chart colour to white because we are not going to show high/low banner
                    chartArea.BackColour = new ColourType("#FFFFFF");
                }

                // set the default min and max y value
                var minValue = (from DataRow r in dataTable.Rows select Convert.ToDouble(r["value"])).Min();
                var maxValue = (from DataRow r in dataTable.Rows select Convert.ToDouble(r["value"])).Max();
                double ySpanBuffed = (maxValue - minValue) * 0.2;
                chartArea.AxisY.MinimumSpecified = true;
                chartArea.AxisY.Minimum = minValue - ySpanBuffed;
                chartArea.AxisY.MaximumSpecified = true;
                chartArea.AxisY.Maximum = maxValue + ySpanBuffed;

                // Loop through each response trpe
                foreach (var responseCategory in responseCategoryTypes)
                {
                    // Get data for the current response type and category
                    var dataRows = (from DataRow r in dataTable.Rows orderby r["dateFrom"] where Convert.ToInt32(r["responseTypeID"]) == Convert.ToInt32(responseCategory.ResponseTypeId) && Convert.ToString(r["Category"]) == Convert.ToString(responseCategory.Category) select r);
                    var currHighLow = (from DataRow r in dataRows select new { lowValue = Convert.ToDouble(r["lowValue"]), highValue = Convert.ToDouble(r["highValue"]) }).First();

                    if (singleChart)
                    {
                        // overide min and max y so that we can display the high/low banner for the current series
                        minValue = (from DataRow r in dataRows select Convert.ToDouble(r["value"])).Min();
                        maxValue = (from DataRow r in dataRows select Convert.ToDouble(r["value"])).Max();
                        double minY = currHighLow.lowValue < minValue ? currHighLow.lowValue : minValue;
                        double maxY = currHighLow.highValue > maxValue ? currHighLow.highValue : maxValue;
                        ySpanBuffed = (maxY - minY) * 0.2;
                        chartArea.AxisY.MinimumSpecified = true;
                        chartArea.AxisY.Minimum = minY - ySpanBuffed;
                        chartArea.AxisY.MaximumSpecified = true;
                        chartArea.AxisY.Maximum = maxY + ySpanBuffed;

                        // set the normal range to white background
                        StripLineType stripMed = new StripLineType();
                        stripMed.IntervalOffset = currHighLow.lowValue;
                        stripMed.StripWidth = currHighLow.highValue - currHighLow.lowValue;
                        stripMed.BackColor = new ColourType(System.Drawing.Color.White);
                        chartArea.AxisY.AddStripLine(stripMed);
                    }

                    // Create a series for the current response type
                    SeriesType series = new SeriesType(responseCategory.Category + ":" + responseCategory.ResponseTypeDesc.ToString(), "ChartArea", ChartTypes.Line, ChartValueTypes.DateTime, ChartValueTypes.Double, MarkerStyles.Circle);
                    series.BorderWidth = 3;
                    series.BorderWidthSpecified = true;
                    series.MarkerColor = new ColourType(System.Drawing.Color.White);
                    series.MarkerSizeSpecified = true;
                    series.MarkerSize = 5;
                    series.MarkerBorderColor = new ColourType(System.Drawing.Color.Black);
                    chart.Series.Add(series);

                    // Add the data to the series
                    foreach (var dataRow in dataRows)
                    {
                        series.AddDataPoint(Convert.ToDateTime(dataRow["dateFrom"]).ToString(), Convert.ToDecimal(dataRow["value"]).ToString());
                    }
                }

                // Remove all items from dataTable that we have created charts for(responseCategoryTypes items)
                var badValues = new HashSet<int>(responseCategoryTypes.AsEnumerable().Select(row => row.ResponseTypeId).Distinct());
                if (dataTable.AsEnumerable().Where(row => !(badValues.Contains(row.Field<int>("responseTypeID")))).Count() > 0)
                {
                    dataTable = dataTable.AsEnumerable().Where(row => !(badValues.Contains(row.Field<int>("responseTypeID")))).CopyToDataTable();
                }
                else
                {
                    dataTable.Rows.Clear();
                }

                charting.Charts.Add(chart);
            }

            // return charting
            return charting;
        }

        /// <summary>
        /// Gets multiple charts for the data
        /// </summary>
        /// <param name="context">The context of the web</param>
        /// <param name="dataTable">The datatbale with the data</param>
        /// <returns>A multiple charts</returns>
        private static Charting GetMutipleCharts(HttpContext context, DataTable dataTable)
        {
            Charting charting = new Charting();
            int sessionId = int.Parse(context.Request.QueryString["sessionId"]);
            double rangePercentage = Convert.ToDouble(new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "ResultsViewer", "ChartRangePercentage", "0.4"));
            double valuePercentage = Convert.ToDouble(new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "ResultsViewer", "ChartValuePercentage", "0.4"));

            // Holds the mindate and max date of all charts
            var totalMinDate = Convert.ToDateTime((from DataRow r in dataTable.Rows orderby Convert.ToDateTime(r["dateFrom"]) ascending select r).First()["dateFrom"]);
            var totalMaxDate = Convert.ToDateTime((from DataRow r in dataTable.Rows orderby Convert.ToDateTime(r["dateFrom"]) descending select r).First()["dateFrom"]);

            // Get the buffer used to padd the charts so that a high/low line can be created
            TimeSpan span = totalMaxDate - totalMinDate;
            int buffer = (int)((double)span.TotalDays * 0.1);
            if (buffer == 0)
            {
                buffer = 1;
            }

            ColourType[] colours = { new ColourType("#000000"), new ColourType("#000088"), new ColourType("#008800"), new ColourType("#880000") };
            int colourIndex = 0;
            while (dataTable.Rows.Count > 0)
            {
                // Get all the different response/category types and sort by category, responseTypeID
                var responseCategoryTypes = (from DataRow r in dataTable.Rows orderby r["responseTypeID"] select new { ResponseTypeId = Convert.ToInt32(r["responseTypeID"]), ResponseTypeDesc = Convert.ToString(r["responseTypeDescription"]), Category = Convert.ToString(r["Category"]) }).OrderBy(r => r.Category).ThenBy(r => r.ResponseTypeId).Distinct();

                // Loop through each response trpe
                foreach (var responseCategory in responseCategoryTypes)
                {
                    // Get data for the current response type and category
                    var dataRows = (from DataRow r in dataTable.Rows orderby r["dateFrom"] where Convert.ToInt32(r["responseTypeID"]) == Convert.ToInt32(responseCategory.ResponseTypeId) && Convert.ToString(r["Category"]) == Convert.ToString(responseCategory.Category) select r);
                    var currHighLow = (from DataRow r in dataRows select new { lowValue = Convert.ToDouble(r["lowValue"]), highValue = Convert.ToDouble(r["highValue"]) }).First();
                    var minValue = (from DataRow r in dataRows select Convert.ToDouble(r["value"])).Min();
                    var maxValue = (from DataRow r in dataRows select Convert.ToDouble(r["value"])).Max();
                    double minY = currHighLow.lowValue < minValue ? currHighLow.lowValue : minValue;
                    double maxY = currHighLow.highValue > maxValue ? currHighLow.highValue : maxValue;
                    double ySpanBuffed = (maxY - minY) * 0.2;

                    // Create a new chart 
                    ChartType chart = new ChartType();
                    chart.BackColour = new ColourType("#EEEEEE");

                    // Create charts title, defining its fonttype
                    TitleType title = new TitleType()
                    {
                        Text = responseCategory.Category + " : " + responseCategory.ResponseTypeDesc,
                        AlignmentSpecified = true,
                        Alignment = ContentAlignmentTypes.TopLeft,
                        Font = new FontType()
                        {
                            Name = System.Drawing.FontFamily.GenericSansSerif.ToString(),
                            Size = 9,
                            Style = FontStyleTypes.Bold
                        }
                    };

                    chart.AddTitle(title);

                    // create a new chart area, set up the min and max x values and add to the chart
                    ChartAreaType chartArea = new ChartAreaType("ChartArea");
                    chartArea.AxisX = new AxisType() { IsMarginVisibleSpecified = true, IsMarginVisible = false };
                    chartArea.AxisX.MinimumSpecified = true;
                    chartArea.AxisX.Minimum = totalMinDate.Date.AddDays(-buffer).ToOADate();
                    chartArea.AxisX.MaximumSpecified = true;
                    chartArea.AxisX.Maximum = totalMaxDate.Date.AddDays(buffer).ToOADate();
                    chartArea.AxisX.MajorGrid = new GridType();
                    chartArea.AxisX.MajorGrid.LineColour = new ColourType("#cccccc");
                    chartArea.AxisX.MinorGrid = new GridType() { Enabled = false };

                    chartArea.BackColour = new ColourType("#FBE8E4"); // default back colour is light pink

                    chartArea.AxisY = new AxisType() { IsMarginVisibleSpecified = true, IsMarginVisible = false };
                    chartArea.AxisY.MinimumSpecified = true;
                    chartArea.AxisY.Minimum = minY - ySpanBuffed;
                    chartArea.AxisY.MaximumSpecified = true;
                    chartArea.AxisY.Maximum = maxY + ySpanBuffed;
                    chartArea.AxisY.MajorGrid = new GridType();
                    chartArea.AxisY.MajorGrid.LineColour = new ColourType("#cccccc");
                    chartArea.AxisY.MinorGrid = new GridType() { Enabled = false };

                    // set the normal range to white background
                    StripLineType stripMed = new StripLineType();
                    stripMed.IntervalOffset = currHighLow.lowValue;
                    stripMed.StripWidth = currHighLow.highValue - currHighLow.lowValue;
                    stripMed.BackColor = new ColourType(System.Drawing.Color.White);
                    chartArea.AxisY.AddStripLine(stripMed);
                    chart.ChartAreas.Add(chartArea);

                    // Set the position of the charting pionts area
                    chartArea.InnerPlotPosition = new ElementPositionType();
                    chartArea.InnerPlotPosition.Auto = false;
                    chartArea.InnerPlotPosition.X = 10;
                    chartArea.InnerPlotPosition.Y = 10;
                    chartArea.InnerPlotPosition.Width = 85;
                    chartArea.InnerPlotPosition.Height = 80;

                    // Create a series for the current response type
                    SeriesType series = new SeriesType(responseCategory.Category + ":" + responseCategory.ResponseTypeDesc.ToString(), "ChartArea", ChartTypes.Line, ChartValueTypes.DateTime, ChartValueTypes.Double, MarkerStyles.Diamond);
                    series.BorderWidth = 3;
                    series.BorderWidthSpecified = true;
                    series.MarkerColor = new ColourType(System.Drawing.Color.White);
                    series.MarkerSizeSpecified = true;
                    series.MarkerSize = 5;
                    series.MarkerBorderColor = new ColourType(System.Drawing.Color.Black);
                    chart.Series.Add(series);

                    // Set the series colour
                    series.Colour = colours[colourIndex];
                    colourIndex++;
                    if (colourIndex >= 4)
                    {
                        colourIndex = 0;
                    }

                    // Add the data to the series
                    foreach (var dataRow in dataRows)
                    {
                        series.AddDataPoint(Convert.ToDateTime(dataRow["dateFrom"]).ToString(), Convert.ToDecimal(dataRow["value"]).ToString());
                    }

                    charting.Charts.Add(chart);
                }

                // Remove all items from dataTable that we have created charts for(responseCategoryTypes items)
                var badValues = new HashSet<int>(responseCategoryTypes.AsEnumerable().Select(row => row.ResponseTypeId).Distinct());
                if (dataTable.AsEnumerable().Where(row => !(badValues.Contains(row.Field<int>("responseTypeID")))).Count() > 0)
                {
                    dataTable = dataTable.AsEnumerable().Where(row => !(badValues.Contains(row.Field<int>("responseTypeID")))).CopyToDataTable();
                }
                else
                {
                    dataTable.Rows.Clear();
                }
            }

            // return charting
            return charting;
        }

        /// <summary>
        /// Builds up the table header section for an individual grid which includes
        /// all of the column headers necessary and applicable to certain situations
        /// (e.g. single patient or multi patient, is this discreet or textual data)
        /// </summary>
        /// <param name="headers"></param>
        /// <param name="singlePatient"></param>
        /// <param name="typeDescRequired"></param>
        /// <returns></returns>
        private string ConstructGridHeaders(XElement response, XElement resultItem, IEnumerable<XElement> headers, IEnumerable<XElement> actionHeaders,
            bool singlePatient, bool typeDescColumnRequired, bool isDiscrete)
        {
            StringBuilder headerHtml = new StringBuilder();
            string sortByForResponse = response.Attribute("sortBy").Value.ToLower();
            string sortDirForResponse = response.Attribute("sortDir").Value.ToLower();
            string id = response.Attribute("id").Value;

            // patient name - do not display if single patient:
            if (!singlePatient)
                headerHtml.Append(ConstructHtmlTableHeaderCell(sortByForResponse, sortDirForResponse, "patientName", id, "Patient Name", "left"));

            // date:
            headerHtml.Append(ConstructHtmlTableHeaderCell(sortByForResponse, sortDirForResponse, "dateFrom", id, "Date Requested", singlePatient ? "left" : null));

            if (typeDescColumnRequired)
                headerHtml.Append("<th class=\"NC\">Type</th>");

            foreach (XElement header in headers)
            {
                string chartCheckbox = string.Empty;
                string checkboxId = resultItem.Attribute("categoryID").Value + "-" + header.Attribute("responseTypeID").Value;
                if (singlePatient && isDiscrete)
                {
                    chartCheckbox = string.Format("<input type=\"checkbox\" id=\"{0}\" class=\"responseTypeCheckbox\" onfocus='SetFocus(this);' onclick='ResponseType_CheckboxChanged(this);' />", checkboxId);
                }

                headerHtml.Append("<th class=\"NC\">" + header.Attribute("description").Value + chartCheckbox + "</th>");
            }


            // need to build up headers that are allowed for display:
            foreach (XElement actionHeader in actionHeaders)
            {
                if (IsActionToBeShown(actionHeader))
                {
                    headerHtml.Append(ConstructHtmlTableHeaderCell(sortByForResponse, sortDirForResponse, actionHeader.Attribute("type").Value, id, actionHeader.Attribute("description").Value, null));
                    // sorting disabled at present as causing an error and backend not able to handle it:
                    //headerHtml.Append("<th class=\"NC\">" + actionHeader.Attribute("description").Value + "</th>");
                }
            }

            return headerHtml.ToString();
        }

        /// <summary>
        /// Builds up the table header section for an individual grid which includes
        /// all of the column headers necessary and applicable to certain situations
        /// (e.g. single patient or multi patient, is this discreet or textual data)
        /// </summary>
        /// <param name="response"></param>
        /// <param name="singlePatient"></param>
        /// <param name="actionHeaders"></param>
        /// <returns></returns>
        private string ConstructGridHeadersForDate(XElement response, bool singlePatient, IEnumerable<XElement> actionHeaders)
        {
            StringBuilder headerHtml = new StringBuilder();
            string sortByForResponse = response.Attribute("sortBy").Value.ToLower();
            string sortDirForResponse = "DESC";

            var actionsToShowCount = actionHeaders.Where(h => IsActionToBeShown((h))).Count();

            if (!singlePatient)
            {
                headerHtml.Append("<tr style='border-top:solid 1px black'>");
                headerHtml.Append("<th class=\"NC byDateHeader left right top\" colspan=\"");
                //                headerHtml.Append(3 + (actionsToShowCount > 1 ? (actionsToShowCount - 1) : 0));
                headerHtml.Append(2 + actionsToShowCount);
                headerHtml.Append("\">Patient Details</th>");
                headerHtml.Append("</tr>");
            }

            headerHtml.Append("<tr>");
            headerHtml.Append("<th class=\"NC byDateHeader header1 left");
            if (singlePatient)
            {
                headerHtml.Append(" top");
            }

            headerHtml.Append("\">Date/Time</th>");
            headerHtml.Append("<th class=\"NC byDateHeader header1");
            if (singlePatient)
            {
                headerHtml.Append(" top");
            }

            if (actionsToShowCount == 0)
            {
                headerHtml.Append(" right");
            }

            headerHtml.Append("\">Request</th>");

            // need to build up headers that are allowed for display:
            var actionsShown = 0;
            foreach (XElement actionHeader in actionHeaders)
            {
                if (IsActionToBeShown(actionHeader))
                {
                    actionsShown++;
                    string css = "byDateHeader header2";
                    if (actionsShown == actionsToShowCount)
                    {
                        css += " right";
                    }

                    if (singlePatient)
                    {
                        css += " top";
                    }

                    headerHtml.Append(ConstructHtmlTableHeaderCell(sortByForResponse, sortDirForResponse, actionHeader.Attribute("type").Value, string.Empty, actionHeader.Attribute("description").Value, css));
                }
            }

            headerHtml.Append("</tr>");

            headerHtml.Append("<tr>");
            headerHtml.Append("<th class=\"NC left\" colspan=\"");
            headerHtml.Append(this.ColspanForResult(actionsToShowCount));
            headerHtml.Append("\">Result</th>");
            headerHtml.Append("<th class=\"NC right\" colspan=\"");
            headerHtml.Append(this.ColspanForValue(actionsToShowCount));
            headerHtml.Append("\">Value</th>");

            headerHtml.Append("</tr>");

            headerHtml.Append("<tr>");
            headerHtml.Append(EmptyRowByDate(actionsToShowCount));
            headerHtml.Append("</tr>");
            return headerHtml.ToString();
        }

        private int ColspanForResult(int actionsToShowCount)
        {
            return (2 + actionsToShowCount) / 2;
        }

        private int ColspanForValue(int actionsToShowCount)
        {
            return (2 + actionsToShowCount) - ((2 + actionsToShowCount) / 2);
        }

        /// <summary>
        /// Builds up the table header section for an individual grid which includes
        /// all of the column headers necessary and applicable to certain situations
        /// (e.g. single patient or multi patient, is this discreet or textual data)
        /// </summary>
        private string EmptyRowByDate(int actionsToShow)
        {
            StringBuilder html = new StringBuilder();
            html.Append("<th class=\"empty\">&nbsp;</th>");
            html.Append("<th class=\"empty\">&nbsp;</th>");
            //html.Append("<th class=\"empty\">&nbsp;</th>");
            for (int i = 0; i < actionsToShow; i++)
            {
                html.Append("<th class=\"empty\">&nbsp;</th>");
            }

            return html.ToString();
        }

        /// <summary>
        /// Helper method that encapsulates the creation of a table header in the
        /// grid of results data.
        /// </summary>
        /// <param name="sortByForResponse">Current sort column</param>
        /// <param name="sortDirForResponse">Current sort direction</param>
        /// <param name="sortBy">Desired sort column</param>
        /// <param name="id">Id of the response, used on client to indicate data reloading</param>
        /// <param name="text">Text label for the header cell</param>
        /// <returns></returns>
        private string ConstructHtmlTableHeaderCell(string sortByForResponse, string sortDirForResponse,
            string sortBy, string id, string text, string cssClass)
        {
            string html = "";
            string dir = sortDirForResponse == GRID_SORT_ASC ? GRID_SORT_ASC : GRID_SORT_DESC;
            string sortIndicatorImg = "";
            bool currentCellSortApplied = sortBy.ToLower() == sortByForResponse.ToLower() ? true : false;

            if (currentCellSortApplied)
            {
                if (dir.ToLower() == GRID_SORT_ASC)
                    sortIndicatorImg = " <img src=\"Images/Grid/blackUp.gif\" height=\"3\" width=\"5\" />";
                else
                    sortIndicatorImg = " <img src=\"Images/Grid/blackDown.gif\" height=\"3\" width=\"5\" />";
            }

            //01.07.10 PCannavan - class name added to the 'th' element, which was previously missing, in order to allow correct sorting
            var thClass = string.Empty;
            if (!string.IsNullOrEmpty(sortBy))
            {
                thClass = sortBy;
            }

            if (!string.IsNullOrEmpty(cssClass))
            {
                thClass += " " + cssClass;
            }

            if (!string.IsNullOrEmpty(thClass))
            {
                html += "<th class=\"" + thClass;
            }
            else
            {
                html += "<th";
            }

            if (!String.IsNullOrEmpty(sortBy))
                html += " onclick=\"javascript:Sort_Click('" + id + "', '" +
                    sortBy + "', '" + (currentCellSortApplied && dir.ToLower() == GRID_SORT_ASC ? GRID_SORT_DESC : GRID_SORT_ASC) + "');\"";

            html += ">";

            html += text + sortIndicatorImg + "</th>";

            return html;
        }

        /// <summary>
        /// Constructs the body section for a grid table. This includes all of the rows
        /// that represent a "result". Technically, each column is an individual result
        /// in the background.
        /// 
        /// TFS30872 Added patient id to be passed through to construction of grid
        /// </summary>
        /// <param name="resultItems"></param>
        /// <param name="singlePatient"></param>
        /// <param name="typeDescColumnRequired"></param>
        /// <returns></returns>
        private string ConstructGridBody(IEnumerable<XElement> headers, IEnumerable<XElement> actionHeaders,
            IEnumerable<XElement> resultItems, string categoryId, bool singlePatient, bool typeDescColumnRequired, XElement response, bool isDiscrete)
        {
            StringBuilder bodyHtml = new StringBuilder();
            int requestId;
            string lastType = string.Empty;

            foreach (XElement resultItem in resultItems)
            {
                var matchingItems =
                    resultItems.Where(
                        item => item.Attribute("typeDescription").Value == resultItem.Attribute("typeDescription").Value);
                var headersForResult = headers.Where(h => matchingItems.Descendants("result").Select(r => r.Attribute("responseTypeID").Value).Contains(h.Attribute("responseTypeID").Value));
                if (lastType != resultItem.Attribute("typeDescription").Value)
                {
                    if (!string.IsNullOrEmpty(lastType))
                    {
                        bodyHtml.Append(this.CloseTable());
                    }

                    bodyHtml.Append("<h2>");
                    bodyHtml.Append(resultItem.Attribute("typeDescription").Value);
                    bodyHtml.Append("</h2>");
                    bodyHtml.Append(this.AddTypeTable(response, resultItem, headersForResult, actionHeaders, singlePatient, typeDescColumnRequired, isDiscrete));

                    lastType = resultItem.Attribute("typeDescription").Value;
                }

                if (singlePatient)
                {
                    bodyHtml.Append("<tr>");
                }
                else
                {
                    bodyHtml.Append("<tr class='MULTIPATIENTRow'>");
                }

                IEnumerable<XElement> resultParts = resultItem.Descendants("result");
                IEnumerable<XElement> actions = resultItem.Descendants("action");
                requestId = int.Parse(resultItem.Attribute("requestID").Value);

                //02.02.10 - P.Cannavan - Patient TD has been given an empty class name 'PT', 
                //so an extra class can be assigned (e.g. 'cellHighlight') for a hover event
                //05.02.10 - P.Cannavan - Primary/Secondary Patient Identifiers added to display
                if (!singlePatient) // click function name short to save on data being downloaded 
                    bodyHtml.Append("<td class=\"PT left\" onclick=\"PD('" + resultItem.Attribute("patientID").Value + "');\" >"
                        + resultItem.Attribute("patientName").Value + "<br/>"
                        + resultItem.Attribute("primaryPatientIdentDesc").Value + ": " + resultItem.Attribute("primaryPatientIdent").Value + "<br/>"
                        + resultItem.Attribute("secondaryPatientIdentDesc").Value + ": " + resultItem.Attribute("secondaryPatientIdent").Value
                        + "</td>");

                bodyHtml.Append("<td class=\"NC");
                if (singlePatient)
                {
                    bodyHtml.Append(" left");
                }

                bodyHtml.Append("\">" + resultItem.Attribute("date").Value + "</td>");

                if (typeDescColumnRequired)
                    bodyHtml.Append("<td class=\"NC\">" + resultItem.Attribute("type").Value.Replace(",", ",<br/>").ToString() + "</td>");

                bodyHtml.Append(ConstructGridResultCells(headersForResult, resultParts, resultItem.Attribute("categoryID").Value, requestId, Convert.ToInt32(resultItem.Attribute("patientID").Value)));

                bodyHtml.Append(ConstructGridResultActions(actionHeaders, actions, resultParts, int.Parse(resultItem.Attribute("requestID").Value), null, null, 0));

                bodyHtml.Append("</tr>");
            }

            if (bodyHtml.Length > 0)
            {
                bodyHtml.Append(this.CloseTable());
            }

            return bodyHtml.ToString();
        }

        /// <summary>
        /// Constructs the body section for a grid table. This includes all of the rows
        /// that represent a "result". Technically, each column is an individual result
        /// in the background.
        /// 
        /// TFS30872 Added patient id to contruction of request row
        /// 
        /// </summary>
        /// <param name="resultItems"></param>
        /// <param name="singlePatient"></param>
        /// <param name="typeDescColumnRequired"></param>
        /// <returns></returns>
        private string ConstructGridBodyByDate(IEnumerable<XElement> headers, IEnumerable<XElement> actionHeaders,
            XElement resultItem, bool singlePatient, bool typeDescColumnRequired)
        {
            var actionsToShowCount = actionHeaders.Where(h => IsActionToBeShown((h))).Count();

            StringBuilder bodyHtml = new StringBuilder();

            int patientId = Convert.ToInt32(resultItem.Attribute("patientID").Value);

            if (!singlePatient)
            {
                bodyHtml.Append("<tr>");
                bodyHtml.Append("<td class=\"byDateHeader left right\" colspan=\"");
                bodyHtml.Append(2 + actionsToShowCount);
                bodyHtml.Append("\">");
                bodyHtml.Append(GetPatientDetailsFromElement(resultItem));
                bodyHtml.Append("</td></tr>");
            }

            bodyHtml.Append("<tr>");
            bodyHtml.Append("<td class=\"byDateHeader left\">");
            bodyHtml.Append(resultItem.Attribute("date").Value);
            bodyHtml.Append("</td>");


            bodyHtml.Append("<td class=\"byDateHeader\">");
            bodyHtml.Append(resultItem.Attribute("type").Value.Replace(",", ",<br/>"));
            bodyHtml.Append("</td>");
            IEnumerable<XElement> resultParts = resultItem.Descendants("result");
            IEnumerable<XElement> actions = resultItem.Descendants("action");
            var requestId = int.Parse(resultItem.Attribute("requestID").Value);
            if (actionsToShowCount == 0)
            {
                //bodyHtml.Append("<td class=\"byDateHeader right\">&nbsp;</td>");
            }
            else
            {
                bodyHtml.Append(ConstructGridResultActions(actionHeaders, actions, resultParts, requestId, "byDateHeader", " right", actionsToShowCount));
            }

            bodyHtml.Append("</tr>");

            int requestTypeTableId = new ICWRTL10.TableRead().GetIDFromDescription(this.sessionId, "RequestType");

            var pendingStr = GetPendingString();

            this.AddRequestRow(bodyHtml, requestId, resultParts, headers, pendingStr, requestTypeTableId, actionsToShowCount, patientId);

            return bodyHtml.ToString();
        }

        private void AddRequestRow(StringBuilder html, int requestId, IEnumerable<XElement> results, IEnumerable<XElement> headers, string pendingStr, int requestTypeTableId, int actionsShownCount, int patientId)
        {
            bool isAlternate = false;
            foreach (XElement result in results)
            {
                var responseTypeId = result.Attribute("responseTypeID").Value;
                var responseId = result.Attribute("responseID").Value;
                var isPreliminary = String.IsNullOrEmpty(result.Attribute("preliminary").Value) ||
                                    Convert.ToBoolean(result.Attribute("preliminary").Value);
                var isCancelled = String.IsNullOrEmpty(result.Attribute("ResultDeleted").Value)
                                  ? false
                                  : result.Attribute("ResultDeleted").Value == "1";
                bool isNarrative = false;
                bool isDiscrete = false;

                html.Append("<tr");
                if (isAlternate)
                {
                    html.Append(" class=\"alternateRow\"");
                }

                html.Append(" style=\"border:none\">");

                var header =
                    headers.Where(
                        h =>
                        h.Attribute("responseTypeID") != null && h.Attribute("responseTypeID").Value == responseTypeId).
                        FirstOrDefault();
                html.Append("<td colspan='");
                html.Append(this.ColspanForResult(actionsShownCount));
                html.Append("'");
                if (header == null)
                {
                    html.Append(" class=\"requestCell left\">&nbsp;");
                }
                else
                {
                    html.Append(" class=\"requestCell left\">");
                    html.Append(header.Attribute("description").Value.Replace(" ", "&nbsp;"));
                }

                html.Append("</td>");

                //   Task 64274 16May2013 YB - Reordeded if else statement. rangeTestOutcomeID is obsolete
                if (!String.IsNullOrEmpty(result.Attribute("value").Value))
                    isDiscrete = true;
                else if (String.IsNullOrEmpty(result.Attribute("rangeTestOutcomeID").Value))
                    isNarrative = true;

                var resultDetailsClick = " onclick=\"RD(this," + isNarrative.ToString().ToLower() + ",'" +
                                         requestTypeTableId + "-" + result.Attribute("requestTypeID").Value + "','" +
                                         requestId + "','" + responseTypeId + "');\"";

                html.Append("<td colspan='");
                html.Append(this.ColspanForValue(actionsShownCount));
                html.Append("'");
                if (isCancelled)
                {
                    html.Append(" class=\"resultCancelled requestCell\" ><div>Cancelled</div>");
                }
                else if (isPreliminary)
                    html.Append(" class=\"pVal requestCell\" >" + ConstructGridPendingCellData(pendingStr));
                else if (isNarrative)
                    html.Append(" class=\"tVal requestCell\"" + resultDetailsClick + " id=\"resultCell" + responseId + "\">" +
                                    ConstructGridNarrativeCellData(result, results, patientId));
                else if (isDiscrete)
                    html.Append(" class=\"dVal requestCell\"" + resultDetailsClick + " id=\"resultCell" + responseId + "\">" +
                                    ConstructGridDiscreetCellData(result, results));
                else
                {
                    html.Append(" class=\"mVal requestCell\" id=\"resultCell" + responseId + "\">" +
                                    ConstructGridMissingCellData()); // no result data available
                }

                // close off the cell:
                html.Append("</td>");

                //html.Append("<td class=\"requestCell\">");
                //if (result.Attribute("unitDescription") != null && !string.IsNullOrEmpty(result.Attribute("unitDescription").Value) && result.Attribute("unitDescription").Value.ToUpperInvariant() != "UNKNOWN")
                //{
                //    html.Append(result.Attribute("unitDescription").Value);
                //}
                //else
                //{
                //    html.Append("&nbsp;");
                //}

                //html.Append("</td>");

                //for (int i = 0; i < actionsShownCount; i++)
                //{
                //    html.Append("<td class=\"requestCell\">&nbsp;</td>");
                //}

                html.Append("</tr>");
                isAlternate = !isAlternate;
            }
        }

        /// <summary>
        /// Builds up the cells that make up the rows in the grid. NEEDS to be a result cell
        /// for each header even if the result item has not been supplied.
        /// </summary>
        /// <param name="headers"></param>
        /// <param name="result"></param>
        /// <param name="categoryId">Id of the request/modality/etc in the tree that initiated the request for these results</param>
        /// <param name="requestId">The id of the request that all results belong to</param>
        /// <returns></returns>
        private string ConstructGridResultCells(IEnumerable<XElement> headers, IEnumerable<XElement> resultParts, string categoryId, int requestId, int patientId)
        {
            StringBuilder cellHtml = new StringBuilder();

            bool foundDataForHeader = false;
            string resultDetailsClick = "";
            string responseTypeId = "";
            string responseId = "";
            bool isDiscrete = false;
            bool isNarrative = false;
            bool isPreliminary = false;
            bool isCancelled = false;
            string pendingStr = string.Empty;

            pendingStr = GetPendingString();
            // some results might not be supplied/in the same order for a header
            // so need to match up the expected headers with the supplied results
            // using the responseTypeId value
            foreach (XElement header in headers)
            {
                foundDataForHeader = false; // reset
                foreach (XElement resultPart in resultParts)
                {
                    responseTypeId = resultPart.Attribute("responseTypeID").Value;
                    responseId = resultPart.Attribute("responseID").Value;
                    if (String.IsNullOrEmpty(resultPart.Attribute("preliminary").Value))
                    {
                        isPreliminary = true;
                    }
                    else
                    {
                        isPreliminary = Convert.ToBoolean(resultPart.Attribute("preliminary").Value);
                    }

                    isCancelled = String.IsNullOrEmpty(resultPart.Attribute("ResultDeleted").Value)
                                      ? false
                                      : resultPart.Attribute("ResultDeleted").Value == "1";

                    //   Task 64274 16May2013 YB - Reordeded if else statement. rangeTestOutcomeID is obsolete
                    if (!String.IsNullOrEmpty(resultPart.Attribute("value").Value))
                        isDiscrete = true;
                    else if (String.IsNullOrEmpty(resultPart.Attribute("rangeTestOutcomeID").Value))
                        isNarrative = true;

                    if (header.Attribute("responseTypeID").Value == responseTypeId)
                    {
                        foundDataForHeader = true;
                        // passing in whether or not it's narrative because the client will
                        // show a different size of window - discrete data will be much smaller
                        // in terms of size.
                        // short click function name to save on data being downloaded:
                        resultDetailsClick = " onclick=\"RD(this," + isNarrative.ToString().ToLower() + ",'" + categoryId + "','" + requestId + "','" + responseTypeId + "'," + isCancelled.ToString().ToLower() + ");\"";

                        // several variations on the data that can appear within this cell:
                        // the class names are used to locate the cells to attach hover event based tooltips:
                        // F0067381 27.05.10 PCannavan - Preliminary Result Check added to remove detail and replace with setting defined string

                        if (isCancelled)
                        {
                            cellHtml.Append("<td class=\"resultCancelled\"" + resultDetailsClick + " id=\"resultCell" + responseId + "\"><div class=\"cancelledGridText\">Cancelled</div>");
                        }
                        else if (isPreliminary)
                        {
                            cellHtml.Append("<td class=\"pVal\" >" + ConstructGridPendingCellData(pendingStr));
                        }
                        else if (isNarrative)
                        {
                            cellHtml.Append("<td class=\"tVal\"" + resultDetailsClick + " id=\"resultCell" + responseId + "\">" + ConstructGridNarrativeCellData(resultPart, resultParts, patientId));
                        }
                        else if (isDiscrete)
                        {
                            cellHtml.Append("<td class=\"dVal\"" + resultDetailsClick + " id=\"resultCell" + responseId + "\">" + ConstructGridDiscreetCellData(resultPart, resultParts));
                        }
                        else
                        {
                            // F0056904 - AKnox - 25.06.09
                            // Placed css class for missing result data
                            cellHtml.Append("<td class=\"mVal\" id=\"resultCell" + responseId + "\"><div>" + ConstructGridMissingCellData()); // no result data available
                        }

                        // close off the cell:
                        cellHtml.Append("</td>");
                        break;
                    }
                }

                // potential here for no result data to have actually matched up with
                // a header... check for a match and if none found, add an empty cell
                if (!foundDataForHeader)
                {
                    // F0056904 - AKnox - 25.06.09
                    // Placed css class for missing result data on parent TD cell
                    cellHtml.Append("<td class=\"mVal\">" + ConstructGridMissingCellData() + "</td>");
                }
            }

            return cellHtml.ToString();
        }

        /// <summary>
        /// Responsible for the creation of the 
        /// </summary>
        /// <param name="actionHeaders"></param>
        /// <param name="actions"></param>
        /// <param name="resultParts">This is the grouping of individual results for one row (ie: a request)</param>
        /// <returns></returns>
        private string ConstructGridResultActions(IEnumerable<XElement> actionHeaders, IEnumerable<XElement> actions, IEnumerable<XElement> resultParts,
            int requestId, string cssClass, string lastActionCssClass, int totalShown)
        {
            StringBuilder cellHtml = new StringBuilder();
            bool actionSet = false;
            string responseIdsForRequest = BuildResponseIdListing(resultParts); // comma separated list of response id's for each of the results

            var actionsShown = 0;
            foreach (XElement actionHeader in actionHeaders)
            {
                if (IsActionToBeShown(actionHeader))
                {
                    actionsShown++;
                    // need to figure out if the action is set or not - the only time this will
                    // be set IF and ONLY IF, each of the results have this action set
                    // could have the situation where 3/4 of the results for a request have the
                    // action set (reviewed/actioned etc). In this case, the checkbox will
                    // NOT be checked, ALL results need to have the action set!
                    actionSet = this.IsActionSetForAllResults(actionHeader, resultParts);

                    if (!string.IsNullOrEmpty(lastActionCssClass) && actionsShown == totalShown)
                    {
                        cssClass += lastActionCssClass;
                    }

                    // now go off and construct the checkbox:
                    cellHtml.Append(ConstructGridResultActionCell(actionHeader, actionSet, responseIdsForRequest, requestId, cssClass));
                }
            }

            return cellHtml.ToString();
        }

        /// <summary>
        /// Checks if the passed in action has been set for all the result parts.
        /// </summary>
        /// <param name="actionHeader">The action to look for.</param>
        /// <param name="resultParts">The results to look in</param>
        /// <returns>Whether or not the action is set for all actions.</returns>
        private bool IsActionSetForAllResults(XElement actionHeader, IEnumerable<XElement> resultParts)
        {
            bool actionSet = true;
            foreach (XElement resultPart in resultParts)
            {
                try
                {
                    int val = Convert.ToInt32(resultPart.Attribute(actionHeader.Attribute("type").Value).Value);
                    if (val == 0)
                    {
                        actionSet = false;
                        break;
                    }
                }
                catch
                {
                    actionSet = false;
                    break;
                }
            }

            return actionSet;
        }

        /// <summary>
        /// Builds up a comma separated string of all of the results that make up the
        /// response. E.g. 120,293,394,8933
        /// </summary>
        /// <param name="resultParts"></param>
        /// <returns></returns>
        private string BuildResponseIdListing(IEnumerable<XElement> resultParts)
        {
            string responseIds = "";

            foreach (XElement resultPart in resultParts)
            {
                if (!String.IsNullOrEmpty(responseIds))
                    responseIds += ",";

                responseIds += resultPart.Attribute("responseID").Value;
            }

            return responseIds;
        }

        private string ConstructGridResultActionCell(XElement actionHeader, bool actionSet, string responseIdsForRequest,
            int requestId, string cssClass)
        {
            // if the action is set, not really interested in the value, the
            // fact that it has a value means it should be checked

            // the onclick event of the action cell will need to pass a
            // list of data over in order for it to be saved off correctly
            // and this is determined by its type

            string applyVerbVal = actionHeader.Attribute("applyVerb").Value;
            string typeVal = actionHeader.Attribute("type").Value;
            string descriptionVal = actionHeader.Attribute("description").Value;
            string deactivateVerbVal = actionHeader.Attribute("deactivateVerb").Value;
            string authenticateVal = actionHeader.Attribute("authenticate").Value;
            string preconditionVal = actionHeader.Attribute("precondition").Value;
            string postconditionVal = actionHeader.Attribute("postcondition").Value;
            string noteTypeIDVal = actionHeader.Attribute("noteTypeID").Value;
            string tableIDVal = actionHeader.Attribute("tableID").Value;
            string tableNameVal = actionHeader.Attribute("tableName").Value;
            string hasFormVal = actionHeader.Attribute("hasForm").Value;

            // javascript function name short to save on data being downloaded!
            string id = "cb" + noteTypeIDVal + requestId;
            string tdClass = "action";
            if (!string.IsNullOrEmpty(cssClass))
            {
                tdClass += " " + cssClass;
            }
            string cellHtml = "<td class=\"" + tdClass + "\"><input id='" + id + "'" + (actionSet ? " checked" : "") + " type=\"checkbox\" " +
                string.Format("class=\"{0}\" ", descriptionVal) +
                "onfocus='SetFocus(this);' " +
                "onclick=\"AC(this," +
                "'" + typeVal + "'," +
                //"'" + applyVerbVal + "'," +
                //"'" + descriptionVal + "'," +
                //"'" + deactivateVerbVal + "'," +
                authenticateVal + "," +
                "'" + preconditionVal + "'," +
                //noteTypeIDVal + "," +
                //tableIDVal + "," +
                "'" + tableNameVal + "'," +
                hasFormVal + "," +
                "'" + responseIdsForRequest + "'," +
                "'" + postconditionVal + "'" +
            ");\" /></td>";

            return cellHtml;
        }

        /// <summary>
        /// Builds up the numeric values that sit inside the grid result cells. Could be
        /// one single value, to many values.
        /// </summary>
        /// <param name="discreetValues"></param>
        /// <param name="upperRange"></param>
        /// <param name="lowerRange"></param>
        /// <returns></returns>
        private string ConstructGridDiscreetCellData(XElement currentResultPart, IEnumerable<XElement> allResultParts)
        {
            StringBuilder discreetDataHtml = new StringBuilder();

            // will need to search across all responses where the type is the same
            // across a request. Duplicates need to be combined into one single
            // cell and then ignored in the next pass over, doing this by marking
            // each one processed with an attribute to indicate this.
            bool currentAlreadyProcessed = currentResultPart.Attribute("processed") == null ? false : true;
            bool alreadyProcessed = false;
            string currentResponseTypeId = currentResultPart.Attribute("responseTypeID").Value;
            string currentResponseId = currentResultPart.Attribute("responseID").Value;
            string responseTypeId = "", responseId = "";

            if (!currentAlreadyProcessed)
            {
                // process this cell, then check for duplicates of this type:
                discreetDataHtml.Append(ConstructGridDiscreetCellDataItem(currentResultPart));
                currentResultPart.Add(new XAttribute("processed", "true"));

                // append on the range data (basically a hidden meta data span tag)
                // only need to do this once - use the range on the current response:
                discreetDataHtml.Append(ConstructGridCellRangeText(currentResultPart));

                // now loop through the rest of the result parts to see if there
                // are any duplicate instances
                foreach (XElement resultPart in allResultParts)
                {
                    responseTypeId = resultPart.Attribute("responseTypeID").Value;
                    responseId = resultPart.Attribute("responseID").Value;
                    alreadyProcessed = resultPart.Attribute("processed") == null ? false : true;
                    var isCancelled = string.IsNullOrEmpty(resultPart.Attribute("ResultDeleted").Value) ? false : resultPart.Attribute("ResultDeleted").Value == "1";

                    if (!alreadyProcessed && !isCancelled && (responseTypeId == currentResponseTypeId) && (responseId != currentResponseId))
                    {
                        // duplicate! add this into the same cell:
                        //cancelled will be treated as a seperate cell so, do not consider here
                        discreetDataHtml.Append(ConstructGridDiscreetCellDataItem(resultPart));
                        resultPart.Add(new XAttribute("processed", "true"));
                    }
                }
            }
            /*bool bLower = false;
            bool bHigher = false;
            string resultValCss = "";

            foreach (string discreetValue in discreetValues.Value.Split('|'))
            {
                bLower = !String.IsNullOrEmpty(lowerRange.Value) && (int.Parse(discreetValue) < int.Parse(lowerRange.Value)) ? true : false;
                bHigher = !String.IsNullOrEmpty(upperRange.Value) && (int.Parse(discreetValue) > int.Parse(upperRange.Value)) ? true : false;

                if (bLower || bHigher)
                    resultValCss = " abnormalResultVal";

                discreetDataHtml.Append("<div class=\"discreetResultVal" + resultValCss + "\">" + discreetValue + "</div>");

                if (bLower)
                    discreetDataHtml.Append("<div class=\"abnormalResult\"><img src=\"Images/Grid/redDownArrow.gif\" alt=\"Low\" width=\"16\" height=\"16\" /></div>");
                else if (bHigher)
                    discreetDataHtml.Append("<div class=\"abnormalResult\"><img src=\"Images/Grid/redUpArrow.gif\" alt=\"High\" width=\"16\" height=\"16\" /></div>");

                discreetDataHtml.Append("<br style=\"clear:both;\"/>");
            }

            discreetDataHtml.Append(ConstructGridCellRangeText(upperRange, lowerRange));*/

            return discreetDataHtml.ToString();
        }

        /// <summary>
        /// Creates cell for discrete valie
        /// Task 61692 16April2013 YB - Added "UnitDescription" to result
        /// Task 64274 16May2013 YB - Added valueText, lowerRangeText and upperRangeText
        /// </summary>
        /// <param name="currentResultPart">The result</param>
        /// <returns>Html string for cell</returns>
        private string ConstructGridDiscreetCellDataItem(XElement currentResultPart)
        {
            StringBuilder discreetDataHtml = new StringBuilder();
            string resultValCss = ""; // either "" or "abnormalResultVal"
            string value = currentResultPart.Attribute("value").Value;
            string valueText = currentResultPart.Attribute("valueText").Value;
            string lowerRange = currentResultPart.Attribute("rangerLower").Value;
            string lowerRangeText = currentResultPart.Attribute("rangerLowerText").Value;
            string upperRange = currentResultPart.Attribute("rangerUpper").Value;
            string upperRangeText = currentResultPart.Attribute("rangerUpperText").Value;
            string unitDescription = currentResultPart.Attribute("UnitDescription").Value;
            bool isLower = false, isHigher = false;

            // ensure that values here are numeric before comparing against them:
            // 14-06-10 PCannavan - Regular Expression changed to handle decimal numbers
            Regex numericRegEx = new Regex(@"^[-]?\d+[.\d]*$");
            if (numericRegEx.IsMatch(value))
            {
                // 14-06-10 PCannavan - discreetVal parsed as float number to handle decimals
                if (numericRegEx.IsMatch(lowerRange))
                    isLower = (float.Parse(value) < float.Parse(lowerRange)) ? true : false;
                if (numericRegEx.IsMatch(upperRange))
                    isHigher = (float.Parse(value) > float.Parse(upperRange)) ? true : false;
            }

            if (isLower || isHigher)
                resultValCss = " abnormalVal";

            discreetDataHtml.Append("<div class=\"val" + resultValCss + "\">" + (string.IsNullOrEmpty(valueText) ? value : valueText) + (!string.IsNullOrEmpty(unitDescription) && unitDescription.ToLower() != "none" ? " (" + unitDescription + ")" : "") + "</div>");

            if (isLower)
                discreetDataHtml.Append("<div class=\"abnormalResult\"><img src=\"Images/Grid/redDownArrow.gif\" alt=\"Low\" width=\"16\" height=\"16\" /></div>");
            else if (isHigher)
                discreetDataHtml.Append("<div class=\"abnormalResult\"><img src=\"Images/Grid/redUpArrow.gif\" alt=\"High\" width=\"16\" height=\"16\" /></div>");

            // leave the br in, it's referred to in the css file:
            discreetDataHtml.Append("<br/>");

            return discreetDataHtml.ToString();
        }

        /// <summary>
        /// Used to render a div container when no data exits for both dicrete and narrative results
        /// </summary>
        /// <returns></returns>
        private string ConstructGridMissingCellData()
        {
            // F0056904 - AKnox - 25.06.09
            // Placed css class for missing result data on parent TD cell
            // F0067381 - PCannavan - 05.03.10
            // Removed ? from within div tags 
            return "<div>&nbsp;</div>";
        }

        /// <summary>
        /// Used to display an indicator, stored within the system setting, that the data result is pending
        /// </summary>
        /// <returns></returns>
        private string ConstructGridPendingCellData(string pendingStr)
        {
            // F0067381 - PCannavan 27.05.10
            // New method constucted. This will cater for both interim (Preliminary) results and pending results
            return "<div>&nbsp;" + pendingStr + "</div>";
        }


        /// <summary>
        /// Responsible for constructing a section of invisible meta data in the UI
        /// that will inform the user what the expected range of values is for the
        /// row cell in context (initiated by hovering over the cell)
        /// Task 64274 16May2013 YB - Added lowerRangeText and upperRangeText
        /// </summary>
        /// <param name="response"></param>
        /// <returns></returns>
        private string ConstructGridCellRangeText(XElement response)
        {
            // desired output example (numbers should be replaced with '*' where no value given):
            // <span class=\"normalRangeMetaData\" style=\"display:none;\">22 to 29</span>

            string rangeText = ("<span class=\"normalRangeMetaData\" style=\"display:none;\">");
            string lowerRange = response.Attribute("rangerLower").Value;
            string lowerRangeText = response.Attribute("rangerLowerText").Value;
            string upperRange = response.Attribute("rangerUpper").Value;
            string upperRangeText = response.Attribute("rangerUpperText").Value;

            lowerRange = string.IsNullOrEmpty(lowerRangeText) ? lowerRange : lowerRangeText;
            upperRange = string.IsNullOrEmpty(upperRangeText) ? upperRange : upperRangeText;

            if (!String.IsNullOrEmpty(upperRange) || !String.IsNullOrEmpty(lowerRange))
            {
                // append on the meta data needed when hovering over the cell:
                if (!String.IsNullOrEmpty(lowerRange))
                    rangeText += (lowerRange);
                else
                    rangeText += "*";
                rangeText += " to ";
                if (!String.IsNullOrEmpty(upperRange))
                    rangeText += (upperRange);
                else
                    rangeText += "*";
            }
            else
                rangeText += ("Not specified");

            rangeText += ("</span>");

            return rangeText;
        }


        private string ConstructGridNarrativeCellData(XElement currentResultPart, IEnumerable<XElement> allResultParts, int patientId)
        {
            StringBuilder textDataHtml = new StringBuilder();
            string responseDescription = "";
            string imageUrl = "";
            bool hasNotes = false, lastNode = false;
            bool alreadyProcessed = false;
            int currentResponseTypeId = 0, responseTypeId = 0, responseId = 0, currentResponseId = 0;

            // use the current result part and add it to the cell BUT
            // only if it hasn't already been added because it's a
            // duplicate result!!!

            alreadyProcessed = currentResultPart.Attribute("processed") == null ? false : true;
            responseDescription = currentResultPart.Attribute("responseDescription").Value;
            hasNotes = Boolean.Parse(currentResultPart.Attribute("hasNotes").Value);
            imageUrl = currentResultPart.Attribute("imageUrl").Value;
            currentResponseTypeId = int.Parse(currentResultPart.Attribute("responseTypeID").Value);
            currentResponseId = int.Parse(currentResultPart.Attribute("responseID").Value);

            if (!alreadyProcessed)
            {
                textDataHtml.Append(ConstructGridNarrativeCellDataItem(responseDescription, hasNotes && allResultParts.Count() == 1, imageUrl, patientId));
                currentResultPart.Add(new XAttribute("processed", "true"));

                // now loop through the rest of the result parts to see if there
                // are any duplicate instances
                int ctr = 0;
                foreach (XElement resultPart in allResultParts)
                {
                    if (ctr + 1 == allResultParts.Count())
                        lastNode = true;

                    responseDescription = resultPart.Attribute("responseDescription").Value;
                    if (!hasNotes)
                        hasNotes = Boolean.Parse(resultPart.Attribute("hasNotes").Value);
                    alreadyProcessed = resultPart.Attribute("processed") == null ? true : false;
                    responseTypeId = int.Parse(resultPart.Attribute("responseTypeID").Value);
                    responseId = int.Parse(resultPart.Attribute("responseID").Value);

                    // check that the type is the same AND we're not looking at the same
                    // current result (or you will replicate a line!):
                    if (responseTypeId == currentResponseTypeId && responseId != currentResponseId)
                    {
                        // duplicate! add this into the same cell:
                        textDataHtml.Append(ConstructGridNarrativeCellDataItem(responseDescription, hasNotes && lastNode, imageUrl, patientId));
                        resultPart.Add(new XAttribute("processed", "true"));
                    }

                    ctr++;
                }
            }

            return textDataHtml.ToString();
        }

        /// <summary>
        /// Responsible for displaying textual data within a cell. A "sticky" notes
        /// icon should also be displayed if notes are present against this result
        /// </summary>
        /// <param name="responseDescription"></param>
        /// <param name="insertStickyNote"></param>
        /// <param name="imageUrl"></param>
        /// <returns></returns>
        private string ConstructGridNarrativeCellDataItem(string responseDescription, bool insertStickyNote, string imageUrl, int patientId)
        {
            StringBuilder textDataHtml = new StringBuilder();

            // if the display value equals 128 characters, it will have been stripped:
            if (!String.IsNullOrEmpty(responseDescription) && responseDescription.Length >= 128)
                responseDescription += "...";

            textDataHtml.Append("<div class=\"val\">" + responseDescription + "</div>");

            // append on a sticky note icon if ANY of the responses have notes:
            // TFS30872 Added display of camera into the grid if a url exists
            if (insertStickyNote)
                textDataHtml.Append("<span>&nbsp;<img src=\"Images/Grid/stickyNote.gif\" alt=\"Notes available\" width=\"16\" height=\"16\" />");

            if (imageUrl.Length > 0)
                textDataHtml.Append("&nbsp;<img src=\"Images/Grid/camera_small.png\" alt=\"Image available\" width=\"16\" height=\"16\" border=\"0\" onclick=\"javascript:DisplayImageInWindow(" + sessionId + "," + patientId + ",'" + imageUrl + "');event.cancelBubble = true;\">");

            textDataHtml.Append("</span>");

            // add a line break and clear the floats (i.e. next row will be on a new line):
            // leave the br in, it's referred to in the css file:
            textDataHtml.Append("<br/>");

            return textDataHtml.ToString();
        }

        /// <summary>
        /// Looks at the ICW desktop params and performs a check to see if
        /// the action is to be displayed using a filter mode (eg: include or exclude)
        /// </summary>
        /// <param name="actionHeader">The action header currently being looked at</param>
        /// <returns></returns>
        private bool IsActionToBeShown(XElement actionHeader)
        {
            // match the header type with the icw desktop params passed in over
            // the querystring and filter:

            bool match = false;
            string actionHeaderType = "";

            if (!this.resultsViewerActionsAllowed)
            {
                // User is not allowed to perform actions therefore dont show the action
                return false;
            }

            if (statusNoteFilter != null) // will be the case if the desktop parameter hasnt been set up
            {
                foreach (string noteType in statusNoteFilter)
                {
                    actionHeaderType = actionHeader.Attribute("type") != null ?
                        actionHeader.Attribute("type").Value.ToLower() : "";

                    match = noteType.ToLower().Equals(actionHeaderType);
                    if (statusNoteFilterAction == StatusNoteFilterAction.EXCLUDE && match)
                        return false;
                    else if (statusNoteFilterAction == StatusNoteFilterAction.INCLUDE && match)
                        return true;
                }
            }
            else
                return true; // return all if not set up

            // if we didnt find a match and the filter is to include, exclude it:
            if (!match && statusNoteFilterAction == StatusNoteFilterAction.INCLUDE)
                return false;

            return true; // if no filter found, show it
        }

        /// <summary>
        /// Creates a user specific quick search with both the filter
        /// criteria and any type of result(s)
        /// </summary>
        /// <returns></returns>
        private string CreateQuickSearch()
        {
            PRVRTL10.QuickSearch objQuickSearch = new PRVRTL10.QuickSearch();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();
            string description = string.Empty;
            string treeItems = string.Empty;
            bool alreadyExists = false;

            PopulateFilterData(ref objResultFilter);
            PopulateQuickSearchData(ref description, ref treeItems);

            string id = objQuickSearch.QuickSearchInsert(sessionId, description, objResultFilter, treeItems, ref alreadyExists).ToString();

            if (alreadyExists)
                return "-1";
            else
                return id;
        }

        /// <summary>
        /// Takes an existing users quick search and updates both the filter
        /// criteria and any type of result(s)
        /// </summary>
        /// <returns></returns>
        private string UpdateQuickSearch()
        {
            PRVRTL10.QuickSearch objQuickSearch = new PRVRTL10.QuickSearch();
            PRVRTL10.ResultFilter objResultFilter = new PRVRTL10.ResultFilter();
            string description = string.Empty;
            string treeItems = string.Empty;
            bool alreadyExists = false;
            int quickSearchId = int.Parse(context.Request.QueryString["quickSearchId"]);

            PopulateFilterData(ref objResultFilter);
            PopulateQuickSearchData(ref description, ref treeItems);

            string id = objQuickSearch.QuickSearchUpdate(sessionId, quickSearchId, description, objResultFilter, treeItems, ref alreadyExists).ToString();

            if (alreadyExists)
                return "-1";
            else
                return id;
        }

        /// <summary>
        /// One central method for pulling out data of the url querystring
        /// and then to populate the PRVRTL10.ResultFilter object with this data
        /// </summary>
        /// <param name="objFilter"></param>
        private void PopulateFilterData(ref PRVRTL10.ResultFilter objFilter)
        {
            PopulateFilterData(this.context, ref objFilter);
        }

        /// <summary>
        /// One central method for pulling out data of the url querystring
        /// and then to populate the PRVRTL10.ResultFilter object with this data
        /// </summary>
        /// <param name="objFilter"></param>
        private static void PopulateFilterData(HttpContext context, ref PRVRTL10.ResultFilter objFilter)
        {
            string consultantId = context.Request.QueryString["consultantId"];
            string locationId = context.Request.QueryString["locationId"];
            string patientTypeId = context.Request.QueryString["patientTypeId"];
            string patientId = context.Request.QueryString["patientId"];
            string dateFrom = context.Request.QueryString["dateFrom"];
            string forPreviousDays = context.Request.QueryString["forPreviousDays"];
            string includeRead = context.Request.QueryString["includeRead"];

            Regex numericRegEx = new Regex(@"^\d+$");
            Regex boolRegEx = new Regex(@"^true|false$");

            if (numericRegEx.IsMatch(consultantId))
                objFilter.ConsultantId = int.Parse(consultantId);
            else
                objFilter.ConsultantId = null;

            if (numericRegEx.IsMatch(locationId))
                objFilter.LocationId = int.Parse(locationId);
            else
                objFilter.LocationId = null;

            if (numericRegEx.IsMatch(patientTypeId))
                objFilter.PatientTypeId = int.Parse(patientTypeId);
            else
                objFilter.PatientTypeId = null;

            if (numericRegEx.IsMatch(patientId))
                objFilter.PatientId = int.Parse(patientId);
            else
                objFilter.PatientId = null;

            if (numericRegEx.IsMatch(forPreviousDays))
                objFilter.ForPreviousDays = int.Parse(forPreviousDays);

            // AKnox - Fix to deal with current days results not coming through, presently
            // only looking at current date at midnight as no time is passed through
            if (String.IsNullOrEmpty(dateFrom))
                objFilter.DateFrom = DateTime.Parse(DateTime.Now.ToString("d") + " 23:59:00");
            else
                objFilter.DateFrom = DateTime.Parse(dateFrom + " 23:59:00");

            if (boolRegEx.IsMatch(includeRead))
                objFilter.IncludeRead = Boolean.Parse(includeRead);
            else
                objFilter.IncludeRead = null;
        }

        private static bool DoFullSearch(HttpContext context)
        {
            return context.Request.QueryString["displaymode"] == "date";
        }

        /// <summary>
        /// Central method for pulling in url querystring data specific to the quicksearch functionality
        /// </summary>
        /// <param name="description"></param>
        /// <param name="treeItems">Pipe delimited string of tree items that have been selected in the order types tree</param>
        private void PopulateQuickSearchData(ref string description, ref string treeItems)
        {
            description = context.Request.QueryString["description"];
            treeItems = context.Request.QueryString["treeItems"];
        }

        /// <summary>
        /// Remove a users quick search from the system
        /// </summary>
        /// <returns></returns>
        private string DeleteQuickSearch()
        {
            int quickSearchId = int.Parse(context.Request.QueryString["quickSearchId"]);

            PRVRTL10.QuickSearch objQuickSearch = new PRVRTL10.QuickSearch();

            return objQuickSearch.QuickSearchDelete(sessionId, quickSearchId).ToString();
        }

        /// <summary>
        /// Set size for maximum number of previous days a search can be performed for - based on Patient Mode
        /// </summary>
        /// <returns></returns>
        private string GetMaxPreviousDays()
        {
            // F0067381 PCannavan - Create method
            string maxVal = string.Empty;
            string patientMode = context.Request.QueryString["patientMode"];
            // Obtain the maximum number of digits from configuration:
            GENRTL10.SettingRead objSettingRead = new GENRTL10.SettingRead();

            //F0067381 PCannavan - Corrected in order to capture correct patient mode and system settings
            if (patientMode.Equals("0"))
                maxVal = objSettingRead.GetValue(sessionId, "OCS", "ResultsViewer", "ForThePrevious(SinglePatient)", "4");
            else
                maxVal = objSettingRead.GetValue(sessionId, "OCS", "ResultsViewer", "ForThePrevious(Multi-Patient)", "3");

            return maxVal;
        }

        /// <summary>
        /// Retrive string representation for pending results from the setting table
        /// </summary>
        /// <returns></returns>
        private string GetPendingString()
        {
            // F0067381 27.05.10 PCannavan - Create Method
            GENRTL10.SettingRead objSettingRead = new GENRTL10.SettingRead();

            return objSettingRead.GetValue(sessionId, "OCS", "ResultsViewer", "PendingResult", "P");
        }

        private string GetDefaultSinglePatientDisplayMode()
        {
            GENRTL10.SettingRead objSettingRead = new GENRTL10.SettingRead();

            return objSettingRead.GetValue(sessionId, "OCS", "ResultsViewer", "SinglePatientDefaultDisplayMode", "modality");
        }

        private string GetDefaultMultiPatientDisplayMode()
        {
            GENRTL10.SettingRead objSettingRead = new GENRTL10.SettingRead();

            return objSettingRead.GetValue(sessionId, "OCS", "ResultsViewer", "MultiPatientDefaultDisplayMode", "modality");
        }

        /// <summary>
        /// Pull out the session id out from the querystring
        /// </summary>
        private void ExtractSessionIdFromQuerystring()
        {
            sessionId = int.Parse(context.Request.QueryString["sessionId"]);
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
