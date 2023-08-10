<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Method</title>

    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"       rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("1005px", (screen.height - 600) + "px");

        setTimeout(function ()
        {
            var heCurrent = document.getElementById('HEdit0');
            var filename = getURLParameter('localFile');
            heCurrent.LoadDoc(filename, 3);
            heCurrent.BackColor = 0xffffff;
            heCurrent.MenuBar   = false;
            heCurrent.StatusBar = false;
            heCurrent.StyleBar  = false;
            heCurrent.Ruler     = false;
            heCurrent.Tabulator = false;
            heCurrent.ReadOnly  = true;
            document.getElementById('divHEdit').style.height = '100%';
        }, 500);
    </script>
</head>
<body onkeyup="if (event.keyCode == 27) { window.close(); }">
    <div id='divHEdit' style="width:100%;height:0px;">
        <OBJECT id="HEdit0" style="width:100%;height:100%" classid=CLSID:ADB3ECE0-1873-11D0-99B4-00550076453D VIEWASTEXT />
    </div>
</body>
</html>
