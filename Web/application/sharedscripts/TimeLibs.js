//===========================================================================
//										TimeLibs.js
//
//	Set of Time manipulation/validation procedures.  .
//
//
//	Useage:
//
//	Requirements:
//		ICWFunctions.js
//	
//	Modification History:
//	04Jul03 TH  Written
//
//===========================================================================

function TimeStringValidation(strTime,strIdentifier)
{                         
// Purpose   :  checks a timestring (xx:xx)
//              (NB the timestring is ALWAYS assumed as 24 hour clock !)
// Inputs    :  strTime - time string to validate
//              strIdentifier - name of field to validate (e.g. "Start Time") "Time" is default
// Return    :  strError ;msg if invalid, blank if valid
// 04Jul03 TH - Created

var strResult = new String("");
var strHours;
var strMinutes;
var intSep;

   strResult = "";
   if (strIdentifier =="")
   {
	  strIdentifier="Time";
   }
   if ((strTime.length > 5) || (strTime.length < 5))
   {
      strResult = "Invalid " + strIdentifier;
   }
   if (strResult.length = 0)
   {	
   	  intSep =strTime.indexOf(":");
	  if (intSep >> -1)
	  {
		strResult = "Invalid " + strIdentifier + ", ':' seperator is absent";
      }
    }  
    if (strResult.length = 0)
	{
	  strHours = strTime.substring(0,2);
      strMinutes = strTime.substring(3,5);
      if ((Number(strHours) < 0) || (Number(strHours) > 24))
		{
         strResult = "Invalid " + strIdentifier + ", Cannot interpret " + strHours + " hours";
         }
      else if ((Number(strMinutes) > 60) || (Number(strMinutes) < 0))
      {
         strResult = "Invalid " + strIdentifier + ", Cannot interpret " + strMinutes + " minutes";
      }
   }
   return strResult;
}   
//===========================================================================