
// ------------------------------- MenuScript.js ------------------------------------
//
// A series of shared functions for the MenuDesigner and Menu ASP pages
//
// 11Jun03 DB Created
// ----------------------------------------------------------------------------------

Const string IMAGE_PATH = "../../Images/User/";

Const int BACKSPACE_KEY = 8;
Const int TAB_KEY = 9;
Const int RETURN_KEY = 13;
Const int ALT_KEY = 18;
Const int ESCAPE_KEY = 27;
Const int SPACE_BAR = 32;
Const int LEFT_ARROW = 37;
Const int UP_ARROW = 38;
Const int RIGHT_ARROW = 39;
Const int DOWN_ARROW = 40;
Const int DELETE_KEY = 46;
Const int m_strDefaultName = "unnamed";

public string HotKeyDisplay(string strDescription, string strKey)
{

// Finds the position of strKey within strDescription and underlines that
// character
// for example 'File' with 'F' as strKey would return
// <U>F</U>ile

	string strDescriptionUC = strDescription.toUpperCase();
	
	int lngPosAt;
	
	if (strKey != " ")
	{
		lngPosAt = strDescriptionUC.indexOf(strKey);
	}
	else
	{
		lngPosAt = -1;
	}
	
	string strNewDescription = strDescription;
	int lngLenLastCharPos = strDescription.length - 1;
	
	if (lngPosAt >-1 && strKey != "")
	{
		if (lngPosAt > 0)
		{
			strNewDescription = strDescription.substr(0, lngPosAt);	
			strNewDescription += "<U unselectable='on'>";
		}
		else
		{
			strNewDescription = "<U unselectable='on'>";
		}
		
		strNewDescription += strDescription.substr(lngPosAt,1);
		strNewDescription += "</U>";
		
		
		if (lngPosAt < lngLenLastCharPos)
		{
			lngLenLastCharPos -= lngPosAt; // Number of characters to work from
			strNewDescription += strDescription.substr(lngPosAt+1, lngLenLastCharPos);
		}
		
	}
	
	return strNewDescription;
}