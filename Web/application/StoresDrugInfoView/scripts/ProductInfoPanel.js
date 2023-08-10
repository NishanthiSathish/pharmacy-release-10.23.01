/*

								ProductInfoPanel.js


	Specific script for the ProductInfoPanel frame.

*/

// Handles editing of (F2) notes.
function lblEditNotes_onclick(note)
{
    // Display input box to allow user to enter new notes
    var txtNotes = InputBox('Edit Product Notes', 'Enter new product notes', 'OkCancel', note, 'ANY');
    
    // If notes entered then validate at server
    // The server responds using ReceiveServerData below
    if (txtNotes != null)
        __doPostBack('upNotes', 'SaveNote:' + txtNotes);
}
