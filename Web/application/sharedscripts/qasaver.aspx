<%@ Page Language="C#" AutoEventWireup="true" CodeFile="qasaver.aspx.cs" Inherits="application_sharedscripts_qasaver" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../sharedscripts/ASPHeader.aspx" />
    <%
        int m_lngSessionID;
        string m_strTableName;
        int m_lngRowID;
        string m_mode;
            
        ICWRTL10.Row objRow;
        m_lngSessionID = Convert.ToInt32(Request.QueryString["SessionID"]);
        m_strTableName = Request.QueryString["TableName"];
        m_lngRowID = Convert.ToInt32(Request.QueryString["RowID"]);
        m_mode = Request.QueryString["Mode"];
        objRow = new ICWRTL10.Row();
    
        if(m_mode != null && m_mode.ToLower() == "resetqa")
        {
            objRow.QAReset(m_lngSessionID, m_strTableName, m_lngRowID);
        }
        else
        {
            objRow.QA(m_lngSessionID, m_strTableName, m_lngRowID);
        }
        
    %>
</head>
<body>
    <form id="frmQASaver" runat="server">
    <div>
        Saving QA status...<br />
        <br />
        Table Name:
        <%= Request.QueryString["TableName"] %>
        <br />
        Row ID:
        <%= Request.QueryString["RowID"]%>
        <br />
        <script type="text/javascript" language="javascript">
            window.parent.QASaveComplete();
        </script>
    </div>
    </form>
</body>
</html>
