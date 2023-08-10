<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("300px", "400px");
    </script>
</head>
<body style="background: #d6e3ff">
    <div style="font:16px arial;color:#ee2d00;position:absolute;top:50%;width:98%;vertical-align:middle;text-align:center;">
        <%= Request["ErrorMessage"] %>
    </div>
</body>
</html>
