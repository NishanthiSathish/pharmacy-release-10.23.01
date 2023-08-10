<%@ webhandler language="C#" class="EpisodeEventHelper" %>

using System;
using System.Web;
using System.Xml;

using ENTRTL10;
using TRNRTL10;

public class EpisodeEventHelper : IHttpHandler
{

	const string INCOMPLETE_PARAMETER_SET = "{ \"message\" : \"Some Parameters Were Missing\" }";
	const string NO_METHOD_SPECIFIED = "{ \"message\" : \"No method was specified\" }";
	const string QUERY_RETURNED_NO_RECORDS = "{ \"message\" : \"Your query returned no results\" }";

	public void ProcessRequest( HttpContext context )
	{
        //System.Diagnostics.Debugger.Break();        
        
		context.Response.ContentType = "application/json; charset=utf-8";
		if ( !string.IsNullOrEmpty(context.Request.QueryString["method"]) )
		{
            string method = context.Request.QueryString["method"] ?? "";
			int sessionid = (string.IsNullOrEmpty(context.Request.QueryString["session"])||context.Request.QueryString["session"]== "null") ? 0 : Convert.ToInt32(context.Request.QueryString["session"]);
            int episode;
            int entity;
            string episodeGUID;
            string entityGUID;

			switch ( method )
			{
				case "rEpisodeSelected":

                    episode = string.IsNullOrEmpty(context.Request.QueryString["episode"]) ? 0 : Convert.ToInt32(context.Request.QueryString["episode"]);
                    entity = string.IsNullOrEmpty(context.Request.QueryString["entity"]) ? 0 : Convert.ToInt32(context.Request.QueryString["entity"]);
                    episodeGUID = context.Request.QueryString["episodeguid"] ?? "";
                    entityGUID = context.Request.QueryString["entityguid"] ?? "";

                    if ( episode < 1 && sessionid < 1 ) { context.Response.Write(INCOMPLETE_PARAMETER_SET); }

					if ( entity < 1 )
					{
						var episodeRead = new EpisodeRead();
						entity = episodeRead.EntityIDFromEpisode(sessionid, episode);
					}

					context.Response.Write(rEpisodeSelected(episode, entity, sessionid));

					break;
				case "eEpisodeSelected":
                    episode = string.IsNullOrEmpty(context.Request.QueryString["episode"]) ? 0 : Convert.ToInt32(context.Request.QueryString["episode"]);
                    entity = string.IsNullOrEmpty(context.Request.QueryString["entity"]) ? 0 : Convert.ToInt32(context.Request.QueryString["entity"]);
                    episodeGUID = context.Request.QueryString["episodeguid"] ?? "";
                    entityGUID = context.Request.QueryString["entityguid"] ?? "";

                    context.Response.Write(eEpisodeSelected(episodeGUID, entityGUID, sessionid));
					break;

                case "GetCurrentEntityEpisodeJson":
                    context.Response.Write(GetCurrentEntityEpisodeJson(sessionid));
                    break;

                case "SetEntityEpisode":
                    episodeGUID = context.Request.QueryString["episodeguid"] ?? "";
                    entityGUID = context.Request.QueryString["entityguid"] ?? "";

                    context.Response.Write(SetEntityEpisode(sessionid, entityGUID, episodeGUID));
                    break;

                case "SetEntity":
                    entityGUID = context.Request.QueryString["entityguid"] ?? "";

                    context.Response.Write(SetEntity(sessionid, entityGUID));
                    break;

                case "ClearEpisode":
                    
                    GENRTL10.State objState = new GENRTL10.State();
                    objState.SetKey(sessionid, "Episode", -1);
                    objState.SetKey(sessionid, "Entity", -1);
                    
                    break;
                    
                default:
					break;
			}
		}


	}

	public bool IsReusable
	{
		get
		{
			return false;
		}
	}


	/// <summary>
	///  Method to return ICWEpisodeEvent, Version Identifier, on the Event Raise
	/// </summary>
	/// <param name="EpisodeID"></param>
	/// <param name="EntityID"></param>
	/// <param name="SessionID"></param>
	/// <returns>JSON String</returns>
	private string rEpisodeSelected( int EpisodeID, int EntityID, int SessionID )
	{

        
		if ( EpisodeID < 1 || EntityID < 1 || SessionID < 1 ) { return INCOMPLETE_PARAMETER_SET; }

		var tmpTransport = new Transport();
		var routineRead = new ICWRTL10.RoutineRead();
		var xmlDoc = new XmlDocument();

		string viParams = routineRead.CreateParameter("episodeID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, EpisodeID);
		viParams += routineRead.CreateParameter("entityID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, EntityID);

        var responseXML = tmpTransport.ExecuteSelectStreamSP(SessionID, "pGetEpisodeAndEntityVidXML", viParams);

		if ( string.IsNullOrEmpty(responseXML) )
		{
			return QUERY_RETURNED_NO_RECORDS;
		}
		else
		{
			xmlDoc.LoadXml("<root>" + responseXML + "</root>");
		}


		string ResponseJSON = String.Format(
            @"'EntityEpisode' : {{'vidEpisode' : {{'GUID' : '{0}','Version' : {1},'EpisodeID' : {4} }},'vidEntity' : {{'GUID' : '{2}','Version' : {3},'EntityID' : {5}}}}}"
                                                                 , xmlDoc.DocumentElement["Entity"].FirstChild.Attributes["GUID"].Value,
																   xmlDoc.DocumentElement["Entity"].FirstChild.Attributes["Version"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].Attributes["_RowGUID"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].Attributes["_RowVersion"].Value,
                                                                   EpisodeID,
                                                                   EntityID
																   ).Replace("'", "\"");

		return "{" + ResponseJSON + "}";
	}

	/// <summary>
	/// 
	/// </summary>
	/// <param name="EpisodeGUID"></param>
	/// <param name="EntityGUID"></param>
	/// <param name="SessionID"></param>
	/// <returns></returns>
	private string eEpisodeSelected( string EpisodeGUID, string EntityGUID, int SessionID )
	{
		if ( string.IsNullOrEmpty(EpisodeGUID) || string.IsNullOrEmpty(EntityGUID) || SessionID < 1 ) { return INCOMPLETE_PARAMETER_SET; }

		var tmpTransport = new Transport();
		var routineRead = new ICWRTL10.RoutineRead();
		var xmlDoc = new XmlDocument();

		string viParams = routineRead.CreateParameter("episodeGUID", Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier, 38, EpisodeGUID);
		viParams += routineRead.CreateParameter("entityGUID", Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier, 38, EntityGUID);

        var responseXML = tmpTransport.ExecuteSelectStreamSP(SessionID, "pGetEpisodeAndEntityVidByGuidXML", viParams);

		if ( string.IsNullOrEmpty(responseXML) )
		{
			return QUERY_RETURNED_NO_RECORDS;
		}
		else
		{
			xmlDoc.LoadXml("<root>" + responseXML + "</root>");
		}

        //GP 28102011-17480 use ~ to wrap property names etc and not ' because the entity description can have ' within the name so replacing ' with \" will break the JSON object single quotes within the JSON objects valid
        string ResponseJSON = String.Format(
            @" ~EntityEpisode~ : {{~vidEpisode~ : {{~GUID~ : ~{0}~,~Version~ : ~{1}~,~EpisodeID~ : ~{2}~ }},~vidEntity~ : {{~GUID~ : ~{3}~,~Version~ : ~{4}~,~EntityID~ : ~{5}~,~EntityDescription~ : ~{6}~}}}}"
                                                                , xmlDoc.DocumentElement["Episode"].Attributes["EpisodeGUID"].Value,
                                                                   xmlDoc.DocumentElement["Episode"].Attributes["EpisodeVersion"].Value,
                                                                   xmlDoc.DocumentElement["Episode"].Attributes["EpisodeID"].Value,
                                                                   xmlDoc.DocumentElement["Episode"].FirstChild.Attributes["EntityGUID"].Value,
                                                                   xmlDoc.DocumentElement["Episode"].FirstChild.Attributes["EntityVersion"].Value,
                                                                   xmlDoc.DocumentElement["Episode"].FirstChild.Attributes["EntityID"].Value,
                                                                   xmlDoc.DocumentElement["Episode"].FirstChild.Attributes["EntityDescription"] == null ? string.Empty : xmlDoc.DocumentElement["Episode"].FirstChild.Attributes["EntityDescription"].Value
                                                                   ).Replace("~", "\"");

		return "{" + ResponseJSON + "}";
	}

    /// <summary>
    ///  Method to return current Entity Episode JSON
    /// </summary>
    /// <param name="SessionID"></param>
    /// <returns>JSON String</returns>
    private string GetCurrentEntityEpisodeJson(int SessionID)
    {
        var tmpTransport = new Transport();
        var routineRead = new ICWRTL10.RoutineRead();
        var xmlDoc = new XmlDocument();

        var responseXML = tmpTransport.ExecuteSelectStreamSP(SessionID, "pGetCurrentEpisodeAndEntityVidXML", String.Empty);

        if (string.IsNullOrEmpty(responseXML))
        {
            return String.Empty;
        }
        else
        {
            xmlDoc.LoadXml("<root>" + responseXML + "</root>");
        }

        //GP 28102011-17480 use ~ to wrap property names etc and not ' because the entity description can have ' within the name so replacing ' with \" will break the JSON object single quotes within the JSON objects valid
        string ResponseJSON = String.Format(
            @"~EntityEpisode~ : {{~vidEpisode~ : {{~GUID~ : ~{0}~,~Version~ : {1},~EpisodeID~ : {2} }},~vidEntity~ : {{~GUID~ : ~{3}~,~Version~ : {4},~EntityID~ : {5},~EntityDescription~ : ~{6}~}}}}"
                                                                ,  xmlDoc.DocumentElement["Entity"].FirstChild.Attributes["EpisodeGuid"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].FirstChild.Attributes["EpisodeVersion"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].FirstChild.Attributes["EpisodeID"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].Attributes["EntityGuid"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].Attributes["EntityVersion"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].Attributes["EntityID"].Value,
                                                                   xmlDoc.DocumentElement["Entity"].Attributes["EntityDescription"].Value
                                                                   ).Replace("~", "\"");

        return "{" + ResponseJSON + "}";
    }

    /// <summary>
    /// Method to set the current ICW Entity / Episode in session state
    /// </summary>
    /// <param name="SessionID"></param>
    /// <param name="EntityGUID"></param>
    /// <param name="EpisodeGUID"></param>
    /// <returns>SQL output stream</returns>
    private string SetEntityEpisode(int SessionID, string EntityGUID, string EpisodeGUID)
    {
        var tmpTransport = new Transport();
        var routineRead = new ICWRTL10.RoutineRead();

        string viParams = routineRead.CreateParameter("episodeGUID", Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier, 38, EpisodeGUID);
        viParams += routineRead.CreateParameter("entityGUID", Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier, 38, EntityGUID);

        try
        {
            return tmpTransport.ExecuteSelectStreamSP(SessionID, "pSetEntityAndEpisodeByGuid", viParams);
        }
        catch (Exception e)
        {
            var objState = new GENRTL10.State();
            objState.SetKey(SessionID, "Episode", -1);
            objState.SetKey(SessionID, "Entity", -1);
            
            throw e;
        }
    }

    /// <summary>
    /// Method to set the current ICW Entity in session state, and set the episode to be the entity's lifetime episode.
    /// </summary>
    /// <param name="SessionID"></param>
    /// <param name="EntityGUID"></param>
    /// <returns>SQL output stream</returns>
    private string SetEntity(int SessionID, string EntityGUID)
    {
        var tmpTransport = new Transport();
        var routineRead = new ICWRTL10.RoutineRead();

        string viParams = routineRead.CreateParameter("entityGUID", Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier, 38, EntityGUID);

        try
        {
            return tmpTransport.ExecuteSelectStreamSP(SessionID, "pSetEntityByGuidWithLifeTimeEpisode", viParams);
        }
        catch (Exception e)
        {
            var objState = new GENRTL10.State();
            objState.SetKey(SessionID, "Episode", -1);
            objState.SetKey(SessionID, "Entity", -1);
            
            throw e;
        }
    }
}
