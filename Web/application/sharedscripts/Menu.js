
function documentKeyDown() {
    // Event code to capture key up event in the document

    KeyCodesToMenu();
}

function documentKeyUp() {
    // Event code to capture key down event in the document

    // Only capture ALT key down (For Ctrl + Alt to capture top menu highlight (focus))
    if (window.event.keyCode == 18) {
        KeyCodesToMenu();
    }
}

function KeyCodesToMenu() {
    // We don't want to pick up on every key press so filter CTRL too
    if (window.event.ctrlKey) {
        try {
            if (window.event.keyCode != 17) {
                ToolMenuWindow().ApplicationKeyPress(window.event.altKey, window.event.ctrlKey, window.event.keyCode);
            }
        }
        catch (x) { }
    }
}

function ICWCreateNewMenuItem() {
    /// <summary>
    /// Creates a new instance of the menu item to be used to populate the application menu.
    /// It is used to populate the menu returned from ICWGetApplicationMenu() function e.g.
    ///
    /// var appMenu = ICWGetApplicationMenu();
    /// var menuItem = ICWCreateNewMenuItem();
    ///
    /// The object returned from this method is of type ToolMenuItem hence has the following properties:
    ///
    /// menuItem.PictureName = "";       The name of the image file present in folder <icw_web_folder>/images/user/.
    /// menuItem.Description = "";       The menu item description displayed to the user.
    /// menuItem.Detail = "";            The menu item detail displayed when the user hover overs the menu item.
    /// menuItem.EventName = "";         The name of the ICW Event to call which is present in the application window.
    /// menuItem.Divider = false;        Used to specifiy if the menu item is a divider by specifying true. Default is false.
    /// menuItem.ButtonData = "";        The data to pass to the ICW Event which is present in the application window.
    /// menuItem.ToolMenu = new Array(); An array of menu items of type ToolMenu to define the child menu items.
    /// menuItem.ImageUrl = "";          Used instead of PictureName to define a location of the image which exist outside 
    ///                                  of folder &lt;icw_web_folder&gt;/images/user/ e.g. http://integrated_app/icon.gif
    ///
    /// appMenu.ToolMenu.push(menuItem);
    /// </summary>
    /// <returns type="ToolMenuItem" />

    // Need to get the constructor function reference so we can create a new instance
    // as it didn't work with when trying to call the constructor directly e.g.
    // new ToolMenuWindow().ToolMenuItem()
    var toolMenuConstructor = ToolMenuWindow().ToolMenuItem;
    return new toolMenuConstructor();
}

function ICWGetApplicationMenu() {
    /// <summary>
    /// Returns the application menu which is displayed in the top menu bar of ICW window.
    /// Following is an example of how it is called.
    ///
    /// var appMenu = ICWGetApplicationMenu();
    ///
    /// The object returned is of type ToolMenuItem hence has the following properties:
    ///
    /// appMenu.PictureName = "";       The name of the image file present in folder <icw_web_folder>/images/user/.
    /// appMenu.Description = "";       The menu item description displayed to the user.
    /// appMenu.Detail = "";            The menu item detail displayed when the user hover overs the menu item.
    /// appMenu.EventName = "";         The name of the ICW Event to call which is present in the application window.
    /// appMenu.Divider = false;        Used to specifiy if the menu item is a divider by specifying true. Default is false.
    /// appMenu.ButtonData = "";        The data to pass to the ICW Event which is present in the application window.
    /// appMenu.ToolMenu = new Array(); An array of menu items of type ToolMenu to define the menu items.
    /// appMenu.ImageUrl = "";          Used instead of PictureName to define a location of the image which exist outside 
    ///                                 of folder &lt;icw_web_folder&gt;/images/user/ e.g. http://integrated_app/icon.gif
    /// </summary>
    /// <returns type="ToolMenuItem" />

    return ToolMenuWindow().GetApplicationMenu(ICWWindowID());
}

function ICWSetApplicationMenu(toolMenu) {
    /// <summary>
    /// Sets the application menu which is display in the top menu bar of ICW window. The menu is of type ToolMenu.
    /// This method replaces the existing application menu or inserts.
    ///
    /// var appMenu = ICWGetApplicationMenu();
    ///
    /// appMenu.PictureName = "";       The name of the image file present in folder &lt;icw_web_folder&gt;/images/user/ ]-->.
    /// appMenu.Description = "";       The menu item description displayed to the user.
    /// appMenu.Detail = "";            The menu item detail displayed when the user hover overs the menu item.
    /// appMenu.EventName = "";         The name of the ICW Event to call which is present in the application window.
    /// appMenu.Divider = false;        Used to specifiy if the menu item is a divider by specifying true. Default is false.
    /// appMenu.ButtonData = "";        The data to pass to the ICW Event which is present in the application window.
    /// appMenu.ToolMenu = new Array(); An array of menu items of type ToolMenu to define the menu items.
    /// appMenu.ImageUrl = "";          Used instead of PictureName to define a location of the image which exist outside 
    ///                                 of folder &lt;icw_web_folder&gt;/images/user/ e.g. http://integrated_app/icon.gif
    ///
    /// ICWSetApplicationMenu(appMenu);
    /// </summary>
    /// <param name="toolMenu"  type="ToolMenuItem">
    ///    The application menu to replace existing application menu or create it.
    /// </param>
    /// <returns type="ToolMenu" />

    ToolMenuWindow().SetApplicationMenu(ICWWindowID(), toolMenu);
}