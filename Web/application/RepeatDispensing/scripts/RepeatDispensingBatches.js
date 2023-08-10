/*

								RepeatDispensingBatches.js


	Specific script for the RepeatDispensingBatches application.

History
04Apr12 AJK 30997 Process All button text and visibility changes in ChangeStatus and window_onload


*/

//=================================================================================================

var m_trSelected = null; // Stores the currently selected row

//=================================================================================================

function window_onload() {
    if (document.getElementById("txtType").value == 'Patients' || (document.getElementById("txtMode").value == 'Combined' && document.getElementById("txtType").value == 'Batches')) {
        if (document.getElementById("btnProcess") != null) document.getElementById("btnProcess").style.visibility = 'hidden';
        if (document.getElementById("btnProcessAll") != null) document.getElementById("btnProcessAll").style.visibility = 'hidden'; // 04Apr12 AJK 30997 Added
        if (document.getElementById("btnMedSchedule") != null) document.getElementById("btnMedSchedule").style.visibility = 'hidden';
        if (document.getElementById("btnRequirementsRpt") != null) document.getElementById("btnRequirementsRpt").style.visibility = 'hidden';
        if (document.getElementById("btnDelete") != null) document.getElementById("btnDelete").style.visibility = 'hidden';
    }
    var recordID = document.getElementById("txtRowID").value; // Get batch ID from forms hidden field
    if (recordID.length > 0) {
        var numRecords = document.getElementById("tbl").rows.length;
        while (numRecords--) { // Iterate through all rows in table
            var row = document.getElementById("tbl").rows[numRecords]; // Get row
            if (row.children[0].id.length > 7 && row.children[0].id.substring(row.children[0].id.length - 7) == "BatchID") { // If the first child in the row has an ID ending in "BatchID"
                if (recordID == row.children[0].innerText) { // If record ID from hidden textbox matches current row
                    RowSelect(row); // Select row
                }
            }
        }
    }

    if (document.getElementById("btnProcess") != null) document.getElementById("btnProcess").disabled = "";
    if (document.getElementById("btnProcessAll") != null) document.getElementById("btnProcessAll").disabled = "";
    if (document.getElementById("btnMedSchedule") != null) document.getElementById("btnMedSchedule").disabled = "";
    if (document.getElementById("btnRequirementsRpt") != null) document.getElementById("btnRequirementsRpt").disabled = "";
    if (document.getElementById("btnDelete") != null) document.getElementById("btnDelete").disabled = "";
    if (document.getElementById("btnSettings") != null) document.getElementById("btnSettings").disabled = "";
}
//=================================================================================================


function RowMoveCursor(tr) { // Called when cursor is moved between rows
    var trLastRow = m_trSelected; // Remember last selected row
    m_trSelected = tr; // Assign currently selected row

    if (trLastRow != null) { // If a row was previously selected
        SetRowClass(trLastRow); // Set the row class for the previously selected row
        trLastRow.tabIndex = -1; 
    }

    SetRowClass(m_trSelected); // Set the row class for the newly selected row
    m_trSelected.tabIndex = 0;
}


function RowSelect(tr) { // Called when a row is selected
    if (tr != null) { // If a row has been selected
        RowMoveCursor(tr); // Call the move cursor method

    }
}

//=================================================================================================

function grid_onclick() { // Called when an element on the grid is clicked
    var tr = GetTR(event.srcElement); // Get the clicked element
    RowSelect(tr); // Call the row select method
}

//=================================================================================================

function grid_onkeydown() { // Called when a key is pressed on the grid
    if (m_trSelected != null) { // If a row is currently selected
        switch (event.keyCode) { // Check which key was pressed
            case 36: // Home was pressed
                if (tbl.rows.length > 1) // If there are data rows in the table
                {
                    RowSelect(tbl.rows[1]); // Select the first data row
                    tbl.rows[1].scrollIntoView(false); // Ensure row is visible
                }
                event.returnValue = false; // Cancel the event
                break;

            case 35: // End
                if (tbl.rows.length > 1) { // If there are data rows in the table
                    RowSelect(tbl.rows[1]); // Select the first data row
                    var tr = tbl.rows[tbl.rows.length - 1]; // Get the last row
                    while (tr.style.display == "none") { // Iterate backwards finding first unhidden row
                        tr = tr.previousSibling;
                    }
                    RowSelect(tr); // Select the row
                    tr.scrollIntoView(false); // Ensure row is visible
                }
                event.returnValue = false; // Cancel the event
                break;

            case 38: // Up was pressed
                var tr = m_trSelected; // Remember currently selected row
                if (tr.previousSibling != null) { // Ensure there is a row above currently selected row
                    do { // Iterate previous rows to find last unhidden row
                        tr = tr.previousSibling;
                    } while (tr.style.display == "none")
                    if (tr.className != "GridHeading") { // If row is not a heading
                        RowSelect(tr); // Select row
                        tr.scrollIntoView(false); // Ensure row is visible
                    }
                }
                event.returnValue = false; // Cancel event
                break;

            case 40: // Down
                var tr = m_trSelected; // Remember currently selected row
                do { // Iterate next rows to find last unhidden row
                    tr = tr.nextSibling;
                } while (tr != null && tr.style.display == "none")
                if (tr != null) { // If a row was found
                    RowSelect(tr); // Select row
                    tr.scrollIntoView(false); // Ensure row is visible
                }
                event.returnValue = false; // Cancel event
                break;
        }
    }
}

//=================================================================================================


function GetTR(ele) { // Returns the TR element from one of its children
    while (ele.nodeName != "TR") { // Loop while element is not a TR
        ele = ele.parentNode; // Get parent element
    }
    return ele;
}

//=================================================================================================

function SetRowClass(tr) { // Sets the class of a row
    var strClass = "";
    if (tr == m_trSelected) { // If row is the currently selected row
        strClass += "RowSelected "; // Assign "RowSelected" CssClass
        tr.focus(); // Focus on the row
        document.getElementById("txtRowID").value = tr.children[0].innerHTML; // Assign the record ID from the first cells of the row to a hidden textbox
        ChangeStatus(tr);
    }

    if (tr != null) { // If row is not null
        tr.className = strClass; // Set class attribute for row
    }
}

function ChangeStatus(tr) {

    if (tr != null && tr.children[14] != null) {
        document.getElementById("btnProcess").style.visibility = 'visible';
        switch (tr.children[14].innerHTML) {
            case 'New':
                document.getElementById("btnProcess").value = 'Label';
                document.getElementById("btnDelete").style.visibility = 'visible';
                if (document.getElementById("txtMode").value == 'Combined') // 04Apr12 AJK 30997 Added
                {
                    if (document.getElementById("btnProcessAll") != null) document.getElementById("btnProcessAll").style.visibility = 'visible';
                }
                if (document.getElementById("txtType").value == "Batches")
                {
                    document.getElementById("btnMedSchedule").style.visibility = 'visible';
                    document.getElementById("btnRequirementsRpt").style.visibility = 'visible';
                }
                else
                {
                    document.getElementById("btnMedSchedule").style.visibility = 'hidden';
                    document.getElementById("btnRequirementsRpt").style.visibility = 'hidden';
                }
                break;
            case 'Labelled':
                if (document.getElementById("btnProcessAll") != null) document.getElementById("btnProcessAll").style.visibility = 'hidden'; // 04Apr12 AJK 30997 Added
                document.getElementById("btnProcess").value = 'Issue';
                document.getElementById("btnMedSchedule").style.visibility = 'hidden';
                document.getElementById("btnDelete").style.visibility = 'visible';
                if (document.getElementById("txtType").value == "Batches")
                {
                    document.getElementById("btnRequirementsRpt").style.visibility = 'visible';
                }
                else
                {
                    document.getElementById("btnRequirementsRpt").style.visibility = 'hidden';
                }
                break;
            case 'Issued':
                if (document.getElementById("btnProcessAll") != null) document.getElementById("btnProcessAll").style.visibility = 'hidden'; // 04Apr12 AJK 30997 Added
                document.getElementById("btnProcess").value = 'Mark as complete';
                document.getElementById("btnMedSchedule").style.visibility = 'hidden';
                document.getElementById("btnDelete").style.visibility = 'hidden';
                document.getElementById("btnRequirementsRpt").style.visibility = 'hidden';
                break;
        }
    }
    
    
}


function RAISE_RefreshTables(){ // Raises Process_Batch event to the ICW
    ICWEventRaise();
}

function RefreshTables(){ // Refreshes the table if batches are visible by submitting the form
    if (document.getElementById("txtType").value == "Batches") {
        document.getElementById("mainForm").submit();
    }
}

function EVENT_RefreshTables(){ // EVENT listening to ICW broadcast to refresh the table
    RefreshTables();
}

//function processBatch() {
//    if (document.getElementById("txtRowID").value.length > 0) { // If a row is selected
//        //Process Batch
//        switch (document.getElementById("txtMode").Text){
//            case "N": //New - to be Labelled
//                RAISE_Process_Batch(document.getElementById("txtRowID").value, 2);
//                break;
//            case "L": //Labelled - to be Issued
//                RAISE_Process_Batch(document.getElementById("txtRowID").value, 3);
//                break;
//        }                
//    }   
//}

//function RAISE_RepeatDispensing_ProcessBatch(BatchID, Mode, SiteID, SessionID, OCXUrl) {
//    // Listens for "Dispensing_RefreshState" events, and will cqall RefreshState on the objDispense object
//    // 05May04 PH Created
//    ICWEventRaise();
//}

//function EVENT_RepeatDispensing_ProcessBatch(BatchID, Mode, SiteID, SessionID, OCXUrl) {
//    // Listens for "Dispensing_RefreshState" events, and will cqall RefreshState on the objDispense object
//    // 05May04 PH Created
//    ProcessBatch(BatchID, Mode, SiteID, SessionID, OCXUrl);
//}

//function ProcessBatch(BatchID, Mode, SiteID, SessionID) {
//    objDispense.ProcessBatch(BatchID, Mode, SiteID, SessionID, OCXUrl);
//}
