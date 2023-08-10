<!-- 
    Page used to help the process of saving a unicode text file to disk (client side) 
    
    To use this page you will need to include it on your calling page
    <iframe style="display:none;" id="fraSaveAs" src="../pharmacysharedscripts/SaveAs.aspx" border="0" frameborder="no" disabled noresize />
    and then call it using script 
    document.frames['fraSaveAs'].SetSaveAsData('Stock Balance Sheet.csv', csv);
    
    Done this way as seems only way of offering the user a save as option (and passing security issues)

    the page will automatically remove invalid chars from the filename
    
    29May13 XN 27038 Created
    29Nov16 XN 147104 Fixed issue with file being truncated
-->
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string filename = Request.Form["filename"];
        string data     = Request.Form["data"];
        
        if (!string.IsNullOrEmpty(filename))
        {
            Response.Clear();
            Response.AddHeader("Content-Disposition", "attachment;filename=" + filename);
            //Response.AddHeader("Content-Length", (data.Length * 2 + 500).ToString());   // Multiply by 2 for unicode, and add on a few extra bytes else don't get whole doc!!!            
            //Response.ContentEncoding = Encoding.Unicode;
            Response.ContentType = "text/plain";
            //Response.ContentEncoding = Encoding.Unicode;
            Response.BufferOutput = false;
            Response.Write(data);
            Response.End();
            //Response.Flush();
            //Response.Close();    
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <script language="javascript" type="text/javascript">
        function SetSaveAsData(filename, data)
        {
            // If document is undefined (after second call) 
            // submit, and so gets true html back
            // if (document == undefined)   10Jul14 XN 95286 fixed ie9 unknown exception script error if even test document on 2nd call
            if (typeof document != 'object')
                form.submit();
            
            // Submit the data so returns as a save as doc
            document.getElementById('filename').value = filename;
            document.getElementById('data').value     = data
            form.submit();
        }
    </script>
</head>
<body>    
    <form id="form" runat="server" method="post">
        <input type="hidden" id="filename" runat="server" value="" />
        <input type="hidden" id="data"     runat="server" value="" />
    </form>
</body>
</html>
