<%@ Page language="vb" %>
<html>
<head>
    <title>Select reports to print...</title>
    
<script>

function Ready()
{
	frames("fraReportSelector").ShowReportList( window.dialogArguments );
}

</script>

</head>

<frameset>
	<frame application=yes id="fraReportSelector" src="ReportSelector.aspx?<%= Request.QueryString %> ">
</frameset>

</html>

