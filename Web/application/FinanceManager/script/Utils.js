/*

Utils.js


Finanace manager js utils

*/

// Converts setting string to object (will also correct the datetime issue when parsing the JSON.
function GetSettings(settingString)
{
    var settings = JSON.parse(settingString);   

    // Convert settings datetime into actual javascript datetime
    if (settings.startDate != undefined)             
        settings.startDate = new Date(parseInt(settings.startDate.substr (6)));
    if (settings.endDate != undefined)             
        settings.endDate = new Date(parseInt(settings.endDate.substr (6)));
    if (settings.upToDate != undefined)             
        settings.upToDate = new Date(parseInt(settings.upToDate.substr (6)));
        
    return settings;
}

// marshalles the table data (excluding attributes) into a single string
// rows are spearated by rscr (char 30 and char 13), and columns by rs (record separator char 30)
// e.g.
//  {col0}rs{col1}rs{col2}rs{col3}rscr{col0}rs{col1}rs{col2}rs{col3}rscr{col0}rs{col1}rs{col2}rs{col3}rscr
function MarshalRows(table)
{
    var gridStr = '';

    // separator characters
    var cr = String.fromCharCode(13);
    var rs = String.fromCharCode(30);
    var us = String.fromCharCode(31);

    var allRows = $('tr', table);
    $.each(allRows, function() 
        {
            gridStr = gridStr.concat((this.getAttribute("headerRow") != null) ? "h" : "d");
            gridStr = gridStr.concat(rs);

            $.each($('td', this), function() 
                {
                    var jthis = $(this);
                    gridStr = gridStr.concat(jthis.innerWidth()      + us);
                    gridStr = gridStr.concat(jthis.css("text-align") + us);

                    var temp = jthis.css("font-style");
                    gridStr = gridStr.concat((temp == 'italic') ? 'i' : '');
                    temp = jthis.css("font-weight");
                    gridStr = gridStr.concat((temp == 'bold' || temp == 'bolder') ? 'b' : '');
                    gridStr = gridStr.concat(us);

                    if (jthis.css("border-left-style" ) == 'solid')
                        gridStr = gridStr.concat(jthis.css("border-left-width" ) + us + jthis.css("border-left-color" ) + us); 
                    else
                        gridStr = gridStr.concat('0' + us + us);
                    if (jthis.css("border-right-style" ) == 'solid')
                        gridStr = gridStr.concat(jthis.css("border-right-width") + us + jthis.css("border-right-color") + us); 
                    else
                        gridStr = gridStr.concat('0' + us + us);

                    gridStr = gridStr.concat(jthis.css("background-color")  + us);
                    gridStr = gridStr.concat(jthis.css("color")             + us);

                    gridStr = gridStr.concat(jthis.text());
                    gridStr = gridStr.concat(rs)
                });
            gridStr = gridStr.concat(cr);
        });

    return gridStr;        
}
