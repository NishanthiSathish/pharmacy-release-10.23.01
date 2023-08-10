using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using OCSRTL10;

public partial class application_WorklistHelper_WorklistHelper : System.Web.UI.Page
{
	protected void Page_Load(object sender, EventArgs e) { }

	[WebMethod]
	public static IList<int> GetExistingNoteIds(int sessionId, string noteTypeId, string baseType, string typeIds)
	{
		return OrderCommsItemRead.GetExistingNoteIds(sessionId, Convert.ToInt32(noteTypeId), baseType, typeIds);
	}

	[WebMethod]
	public static bool LockRequests(int sessionId, string requestIds)
	{
		RequestLock requestLock = new RequestLock();
		foreach (int requestId in GetRequestIdsFrom(requestIds))
		{
			string result = requestLock.LockRequest(Convert.ToInt32(sessionId), requestId, false);
			if (result != null && result != String.Empty) return false;
		}
		return true;
	}

	[WebMethod]
	public static void UnlockRequests(int sessionId, string requestIds)
	{
		RequestLock requestLock = new RequestLock();
		foreach (int requestId in GetRequestIdsFrom(requestIds))
		{
			requestLock.UnlockMyRequestLock(Convert.ToInt32(sessionId), requestId);
		}
	}

	private static List<int> GetRequestIdsFrom(string commaSeperatedListIds)
	{
		return new List<string>(commaSeperatedListIds.Replace(" ", String.Empty).Split(',')).ConvertAll(x => Convert.ToInt32(x));
	}

}
