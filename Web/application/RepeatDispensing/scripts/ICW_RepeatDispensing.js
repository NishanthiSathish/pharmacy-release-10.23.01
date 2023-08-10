/*

								ICW_RepeatDispensing.js


	Specific script for the RepeatDispensingBatchPatient application.

*/

//=================================================================================================

var m_trSelected = null; // Stores the currently selected row

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
        var lngEpisodeID = tr.getAttribute("e");
        //if (lngEpisodeID != null)                   //DJH TFS18299
		if (lngEpisodeID != null && lngEpisodeID > 0) //DJH TFS18299
		{
			var strURL = "../RepeatDispensing/EpisodeSaver.aspx?SessionID=" + document.body.getAttribute("SessionID") + "&EpisodeID=" + lngEpisodeID;	
			objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							//Create the object
			if(objHTTPRequest != null)
			{
				objHTTPRequest.open("POST", strURL, false);										//false = syncronously
	    		objHTTPRequest.send(null);														//Send the request syncronously
	    		
	    		// 21Feb11 PH Take ICW Episode integer, convert to entity & episode versioned identifiers, and raise the ICW Episode Selected Event
	    		// Create JSON episode event data
	    		//var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(lngSlaveEpisodeID, 0, document.body.getAttribute("SessionID"));   //DJH - 02/09/2011 - Bug 12884
	    		var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(lngEpisodeID, 0, document.body.getAttribute("SessionID"));          //DJH - 02/09/2011 - Bug 12884
	    		// Raise episode event via ICW framework, using entity & episode versioned identifier
	    		RAISE_EpisodeSelected(jsonEntityEpisodeVid);
	    		
//	    		RAISE_EpisodeSelected();
		    }
		    else
		        alert("Create XMLHTTP failed");
		}
		else {                          //DJH TFS18299
		    RAISE_EpisodeCleared();     //DJH TFS18299
		}                               //DJH TFS18299
		
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
				    RowSelect( tbl.rows[1] ); // Select the first data row
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

            case 32: // Spacebar
                var tr = m_trSelected; // Get selected row
                if (tr.children[0].children[0].checked == true) { // If checekbox in first cell is checked - patient selected
                    tr.children[0].children[0].checked = false; // Uncheck checkbox/patient
                }
                else {
                    tr.children[0].children[0].checked = true; // Check checkbox
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
    }

    if (tr != null) { // If row is not null
        tr.className = strClass; // Set class attribute for row
    }

}
