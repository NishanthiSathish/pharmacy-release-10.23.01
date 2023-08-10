//===========================================================================
//
//						  BNFTree.ascx.cs
//
//  Displays all the BNF categories by in a tree layout.
//
//  Set OnClientNodeSelected to get client event when a node is selected.
//  
//  Usage:
//  HTLM
//  <%@ Register src="../PharmacyProductSearch/controls/BNFTree.ascx"  tagname="BNFTree" tagprefix="uc1" %>
//  :
//  <script type="text/javascript" src="scripts/BNFTree.js"></script>
//  :
//  <uc1:BNFTree ID="bnfTree" runat="server" OnClientNodeSelected="bnfTree_OnClientNodeSelected" />
//
//  Server side code
//  bnfTree.Initalise();
//  
//  Client side code
//  function bnfTree_OnClientNodeSelected(bnf)
//  {
//      alert(bfn);
//  }
//
//	Modification History:
//	17Oct14 XN  88560 Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Telerik.Web.UI;

public partial class application_PharmacyProductSearch_controls_BNFTree : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // If BNF selected the reselect (does not work automatically as gtree is dynamically created)
        if ( !string.IsNullOrEmpty(hfSelectedBNFValue.Value) )
            BNFtree.FindChildByValue<RadTreeNode>(hfSelectedBNFValue.Value).Selected = true;
    }

    /// <summary>Client side method called on selection of node</summary>
    public string OnClientNodeSelected { get; set; }

    /// <summary>Populate the list with BNF codes</summary>
    public void Initalise()
    {
        // Get depth
        int depth = WConfiguration.Load<int>(SessionInfo.SiteID, "D|stkmaint", "Display", "BNFlevels", 4, false);
        if ( depth < 1 || depth > 4 )
            depth = 4;

        // Load order catalogues
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.Add("CurrentSessionID", SessionInfo.SessionID);
        parameters.Add("depth",            depth);

        GenericTable2 bnfList = new GenericTable2();
        bnfList.LoadBySP("pOrderCatalogueSelectForPharmacyBNF", parameters);

        BNFtree.Nodes.Clear();

        // Create list of parent nodes from current level
        var parentNodeForDepth = new RadTreeNodeCollection[depth + 1];
        for(int n = 0; n < parentNodeForDepth.Length; n++)
            parentNodeForDepth[n] = null;
        parentNodeForDepth[0] = BNFtree.Nodes;
        
        // Build list
        foreach (var row in bnfList)
        {
            string code  = row.RawRow["code"]  == DBNull.Value ? string.Empty : row.RawRow["code"].ToString();
            string value = row.RawRow["value"] == DBNull.Value ? string.Empty : row.RawRow["value"].ToString();
            int    currentDepth= (code.Length / 3) + 1;

            RadTreeNode node = new RadTreeNode(code + " - " + value, code);
            parentNodeForDepth[currentDepth - 1].Add( node );
            parentNodeForDepth[currentDepth] = node.Nodes;
        }

        // Select to item in tree
        if (BNFtree.Nodes.Count > 0)
            BNFtree.Nodes[0].Selected = true;
    }
}