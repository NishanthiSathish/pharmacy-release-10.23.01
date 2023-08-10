/*

                    ICW_RobotLoading.js


Specific script for the ICW_RobotLoading page.

Handles high level key presses, and provides a method to display Receive Goods 
screen in modal web page.

*/

var RECEIVEGOODSSCREEN_FEATURES = 'dialogHeight:760px; dialogWidth:850px; status:off; center: Yes';

// Handles key presses on the robot loading info screen.
function form_onkeydown(event) 
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 27:    // ESC (close the form only works when page is called from Pharmacy stores application)  
            window.close();
            break;

        case 13:    // Return (switches to next tab)
            __doPostBack('upSelectedTab', 'incrementtab');
            break;
    }
}

// Displays the Receive Goods screen for the order
function displayReceiveGoodsScreen(orderNumber) 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    strURLParameters += "&OrderNumber=" + orderNumber;

    // Displays the suppliers details window
    var ret=window.showModalDialog('../ReceiveGoods/ReceiveGoodsModal.aspx' + strURLParameters, '', RECEIVEGOODSSCREEN_FEATURES);
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}