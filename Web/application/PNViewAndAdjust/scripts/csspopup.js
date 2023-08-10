/*
                csspopup.js
                
    Helper functions to display parts of web page in a popup in middle of page, 
    width blanket for background               
*/

// Get's height of main document window
function getViewHeight()
{
    var height;
    
    if (typeof window.innerHeight != 'undefined') 
		viewportheight = window.innerHeight;
    else 
		viewportheight = document.documentElement.clientHeight;

    if ((viewportheight > document.body.parentNode.scrollHeight) && (viewportheight > document.body.parentNode.clientHeight)) 
		height = viewportheight;
    else if (document.body.parentNode.clientHeight > document.body.parentNode.scrollHeight) 
        height = document.body.parentNode.clientHeight;
    else
        height = document.body.parentNode.scrollHeight;

    return height;        
}

// Get's width of main document window
function getViewWidth()
{
    var width;
    
    if (typeof window.innerWidth != 'undefined') 
		viewportwidth = window.innerWidth;
    else 
		viewportwidth = document.documentElement.clientWidth;

    if ((viewportwidth > document.body.parentNode.scrollWidth) && (viewportwidth > document.body.parentNode.clientWidth)) 
		width = viewportwidth;
    else if (document.body.parentNode.clientWidth > document.body.parentNode.scrollWidth) 
        width = document.body.parentNode.clientWidth;
    else
        width = document.body.parentNode.clientWidth;

    return width;
}

//function displayBlanket(popUpDivVar) 
//{
//    if (typeof window.innerWidth != 'undefined') 
//		viewportheight = window.innerHeight;
//    else 
//		viewportheight = document.documentElement.clientHeight;

//    if ((viewportheight > document.body.parentNode.scrollHeight) && (viewportheight > document.body.parentNode.clientHeight)) 
//		blanket_height = viewportheight;
//    else if (document.body.parentNode.clientHeight > document.body.parentNode.scrollHeight) 
//        blanket_height = document.body.parentNode.clientHeight;
//    else 
//        blanket_height = document.body.parentNode.scrollHeight;

//	var blanket = document.getElementById('blanket');
//	blanket.style.height = blanket_height + 'px';
//	blanket.style.display = "";
//}

//function displayWindow(popUpDivVar)
//{
//    var popUpDiv = document.getElementById(popUpDivVar);
//    var blanket  = popUpDiv.parentNode;

//    popUpDiv.style.display = "";
//    popUpDiv.style.top = (blanket.style.top  + (blanket.clientHeight - popUpDiv.clientHeight) / 2) + 'px';;
//    popUpDiv.style.left= (blanket.style.left + (blanket.clientWidth  - popUpDiv.clientWidth ) / 2) + 'px';;
//}

// displays the specified item in the middle of parent window
// divItem - name of element to display
// height - height of parent
// width  - width of parent
function displayPopupItem(divItem, height, width)
{
    var popUpDiv = document.getElementById(divItem);

    popUpDiv.style.display = "";

    var clientHeight = popUpDiv.clientHeight;
    if (clientHeight == 0)
        clientHeight = height;
    var clientWidth = popUpDiv.clientWidth;
    if (clientWidth == 0)
        clientWidth = width;
    
    popUpDiv.style.top = ((height - clientHeight) / 2) + 'px';;
    popUpDiv.style.left= ((width  - clientWidth ) / 2) + 'px';;
}

// Display item, and blanket
// divItem - Item to display
// blanket - name of the blanket div
function popup(divItem, blanket)
{
    var height = getViewHeight();
    var width = getViewWidth();

    var blanket = document.getElementById(blanket);
    blanket.style.height = height + 'px';
    blanket.style.width  = width  + 'px';
    
	displayPopupItem('blanket', height, width);
	displayPopupItem(divItem,   height, width);
}

// Hide item, and blanket
// divItem - Item to hide
// blanket - name of the blanket div
function hidePopup(divItem, blanket)
{
    document.getElementById(blanket ).style.display = "none";
    document.getElementById(divItem ).style.display = "none";
}