/*

								ICW_StoresDrugInfoView.js


	Specific script for the ICW_StoresDrugInfoView frame.

*/

// Handles key presses on the Stores drug info screen.
function form_onkeydown(event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 27:    // ESC (close the form only works when page is called from Pharmacy stores application)  
        window.close();
        break; 
        
    case 13:    // Return (switches to next tab)
        __doPostBack('upSelectedTab', 'incrementtab');
        event.cancelBubble = true;      // 30Jul15 XN 121034 Prevent event bubbling else need to press enter twice to move the requisition tab
        event.returnValue = false;
        break;
        
    case 113:   // F2 Change product message        
        if (window.frames['fraProductInfoPanel'] != undefined)
            window.frames['fraProductInfoPanel'].window.lblEditNotes_onclick(null);
        break;

    case 115:   // F4 Robot stock enquiry
        $('#hfKeyPress').val(event.keyCode.toString());
        break;
    }
}

// Called by the VB client code
// to update the RobotStockLevel field
function SetRobotStockLevel(stockLevel)
{
    window.frames['fraProductInfoPanel'].setPanelLabel('pnlProductInfoPanel', 'RobotStockLevel', stockLevel);
}