//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TreeView "Properties"
//
// TreeView_NodeSelected(strID)
//

function TreeView_NodeSelected(strID)
{
	return document.all(strID).selectSingleNode('//*[@xtvid="' + document.all("xtvdiv"+strID).getAttribute("xtvid") + '"]');
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TreeView "Methods"
//
// TreeView_NodeSelect(strID, xmlnode)
//

function TreeView_NodeSelect(strID, xmlnode)
{
	TV_NodeSelect(strID, xmlnode);
}

function TreeView_NodeSelectXPath(strID, strXPath)
{
	var xmlnode = document.all(strID).selectSingleNode(strXPath);
	if (xmlnode != null)
	{
		TV_NodeSelect(strID, xmlnode);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TreeView "Events"
//
//	TreeViewItem_onclick(strID, xmlnode);
//

function TV_onclick(strID, xmlnode, objLI)
{
    //02Apr09   Rams    F0048884 - Show a confrim window incase the the child form
    //                  is not saved.
    var oChildState = document.getElementById("txt_ChildState");
    var bDiscard = true;
    if (oChildState != undefined)
    {
	    if (oChildState.value == "true")
	    {   
	        if(window.confirm("Discard changes made ?"))
	        {
                oChildState.value = "false";	            
            }
            else
            {
                bDiscard = false;
            }
        }
    }
    //
    if(bDiscard == true)
	{
	    TV_NodeSelect(strID, xmlnode);
        TreeViewItem_onclick(strID, xmlnode);
	}
	event.cancelBubble=true;  
}

function TV_NodeSelect(strID, xmlnode)
{
	if (document.all("xtvdiv" + strID).getAttribute("xtvid") != null)
	{
		document.getElementById( "xtv" + document.all("xtvdiv" + strID).getAttribute("xtvid") ).firstChild.className = "";
	}
	document.all("xtvdiv" + strID).setAttribute("xtvid", xmlnode.getAttribute("xtvid"))
	document.getElementById( "xtv" + document.all("xtvdiv" + strID).getAttribute("xtvid") ).firstChild.className = "TreeViewNodeSelected";
}