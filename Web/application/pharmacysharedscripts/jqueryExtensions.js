/*

                           jqueryExtensions.js


jquery extension methods

containsi - extension of the jquery :contains selector that is case in-senstive
            $('#ShowItems li:containsi("Share")')

startswithi-extension of the jquery :contains selector that is case in-senstive
            $('#ShowItems li:startswithi("Share")')
            
enable    - method to enable jquery element (set/remove disable attrbiute)
            $('input).enable(false);
            
visible   - method to set jquery element visible
            $('input).visible(false);

tabbingFix- method that will fix the tabbing on jquiery ui dialog 
            (only use if your tabbing is broken)
            use by adding the function to the keydown event handler in the dialog open event
                open: function () { $(this).parent().keydown(function (event) { return tabbingFix(event, this); }); }
*/

/* For example $(‘#ShowItems li:containsi(“Share”)’), then match[3] will be Share*/
$.extend($.expr[':'], 
{
    'containsi': function (elem, i, match, array) 
        {
            return (elem.textContent || elem.innerText || '').toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
        }
});

/* For example $(‘#ShowItems li:startswithi(“Share”)’), then match[3] will be Share*/
$.extend($.expr[':'], 
{
    'startswithi': function (elem, i, match, array) 
        {
            return (elem.textContent || elem.innerText || '').toLowerCase().indexOf((match[3] || "").toLowerCase()) == 0;
        }
});

/* Enables\disable an element $('#itemID').enable(false) will disable #itemID */
$.fn.enable = function(enable) 
{
    if (enable)
        $(this).each(function() { $(this).removeAttr('disabled');       });
    else
        $(this).each(function() { $(this).attr('disabled', 'disabled'); });
};

/* Enables\disable an element $('#itemID').visible(false) will hide #itemID */
$.fn.visible = function(visible) 
{
    if (visible)
        $(this).each(function() { $(this).show(); });
    else
        $(this).each(function() { $(this).hide(); });
};

/* 
fixes tabbing on jquiery ui dialog (only use if your tabbing is broken) 
use by adding the function to the keydown event handler in the dialog open event
    open: function () { $(this).parent().keydown(function (event) { return tabbingFix(event, this); }); }
Note: the method also has to overrides the operation of the shift, space and enter keys
*/
function tabbingFix(event, uiDialog) 
{
    switch (event.keyCode)
    {
    case 16:    // If shift key then skip as this seems to have odd handling of tabbing 
        return false;

    case $.ui.keyCode.TAB:  // If tab key then set next item as in focus
        // get tabbalbe items
        var tabbables = $(":tabbable", uiDialog);

        // Get currently focused items
        var current = $(":focus", uiDialog);
        var index = $.inArray(current[0], tabbables) + (event.shiftKey ? -1 : 1);

        // Move to next tab item
        if (index == -1)
            tabbables.last().focus();
        else if (index == tabbables.length)
            tabbables.first().focus();
        else if (index >= 0)
            tabbables.eq(index).focus();

        return false;
        break;

    case $.ui.keyCode.SPACE:    // If enter or space and on a button then click the button
    case $.ui.keyCode.ENTER:
        var current = $(":focus", uiDialog);
        if (current.is("button")) 
        {
            current.click();
            return false;
        }
        break;
    }
};