/*
HAP toolbar control

Helper functions for the HAP toolbar

Unlike other controls call a javascript function require having a handle to the control object 
by calling method HapToolbar(controlId)

Also buttons are referenced by their ICW name in the toolbar

So to set a couple of button states do
var toolbar = HapToolbar('toolbar');
HapToolbarEnable(toolbar, 'aMMWorkflow_View', true);
HapToolbarEnable(toolbar, 'aMMWorkflow_Copy', false);
*/

// returns the Hap toolbar by id
function HapToolbar(controlId)
{
    var control = document.getElementById(controlId);
    return $find(control.childNodes[0].id);
}

// Updates the state of the toolbar
function HapToolbarEnable(toolbar, eventName, enable)
{
    var button = null;
    if (toolbar != null)
        button = toolbar.findItemByAttribute("eventName", eventName);

    if (button != null)
        button.set_enabled(enable);
}

// called to manually click toolbar button via an button event name
function HapToolbarClick(toolbar, eventName)
{
    var button = toolbar.findItemByAttribute("eventName", eventName);
    if (button != null && button.get_enabled())
        button.click();
}

// Set the image for the hap toolbar
function HapToolbarSetImage(toolbar, eventName, imageUrl)
{
    var button = null;
    if (toolbar != null)
        button = toolbar.findItemByAttribute("eventName", eventName);

    if (button != null)
        button.set_imageUrl(imageUrl);    
}