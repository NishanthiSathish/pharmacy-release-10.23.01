/*

								SupplierDetails.js


	Specific script for the SupplierDetails frame.

*/

// Handles key presses on the Stores drug info screen.
function form_onkeydown(event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 27:    // ESC (close the form only works in Pharmacy application)  
        window.close();
        break; 
    }
}