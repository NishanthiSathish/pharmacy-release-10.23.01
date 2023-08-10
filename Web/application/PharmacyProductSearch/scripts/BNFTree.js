/*

								BNFtree.js


	Specific script for the BNFtree control.

*/

// When node clicked send out client side onClientNodeSelected event
function BNFtree_onNodeClicking(sender, args) 
{
    var bnf = args.get_node().get_value();
    $("[id$='hfSelectedBNFValue']").val(bnf);

    var onClientNodeSelected = $('#' + args.get_node().get_treeView().get_id() ).parents().attr('onClientNodeSelected');
    if (onClientNodeSelected.length > 0)
        eval(onClientNodeSelected + "('" + bnf + "');");
}