
namespace Ascribe.SaveAs
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Xml;
    using System.Xml.Linq;
    
    /// <summary>
    /// Desktop Save As 
    /// </summary>
    public class Desktop
    {
        /// <summary>
        /// Field to store the new desktop description
        /// </summary>
        private readonly string newDesktopDescription = string.Empty;

        private int _ID = -1;
        private int _originalDesktopID = 0;
        private int _newDesktopToolMenuID = 0;
        private int _newDesktopToolbarID = 0;
        private int _originalDesktopToolMenuID = 0;
        private int _originalDesktopToolbarID = 0;

        private bool _copyRoles = false;

        private string _originalDescription = string.Empty;

        private XDocument _xDoc = null;

        private List<ToolMenu> _toolMenus;
        private List<WindowDetail> _windows;
        private List<WindowParameter> _windowParameters;

        /// <summary>
        /// Initializes a new instance of the <see cref="Desktop"/> class. 
        /// </summary>
        /// <param name="xml">xml string to process from view</param>
        /// <param name="newDesktopDescription">New desktop description</param>
        /// <param name="copyRoles">Should copy the roles from existing desktop</param>
        public Desktop(string xml, string newDesktopDescription, bool copyRoles)
        {
            this._xDoc = XDocument.Parse(xml);
            this._windows = new List<WindowDetail>();
            this._toolMenus = new List<ToolMenu>();
            this.newDesktopDescription = newDesktopDescription;
            this._copyRoles = copyRoles;
        }

        /// <summary>
        /// main process method
        /// </summary>
        /// <returns>Modified xmlDocument</returns>
        public XmlDocument Process()
        {
            // get the original ids for the desktop, desktop menu and desktop toolbar
            this.GetDesktopDetails();

            // process windows
            this.ProcessWindows();

            // process window parameters
            this.ProcessWindowPrameters();

            // process toolmenu
            this.ProcessToolMenu();

            // change the desktopID, description and menu IDs
            this.SetDesktopDetails();

            // remove the roles if the setting is false
            if (!this._copyRoles)
            {
                this.RemoveRoles();
            }

            // convert xdocument into xmldocument
            var result = new XmlDocument();
            using (var xmlReader = this._xDoc.CreateReader())
            {
                result.Load(xmlReader);
            }

            return result;
        }

        private void RemoveRoles()
        {
            this._xDoc.Descendants("DesktopRoles").Remove();
        }

        /// <summary>
        /// get next id for window, toolbar etc
        /// </summary>
        private int NextID
        {
            get
            {
                return this._ID--;
            }
        }

        /// <summary>
        /// Process all window elements within the xdocument
        /// </summary>
        private void ProcessWindows()
        {
            // get a list of all windows within the document            
            this._windows = (from window in this._xDoc.Descendants("Window")
                             select new WindowDetail
                             {
                               DesktopID = window.Attribute("DesktopID").Value,
                               WindowID = window.Attribute("WindowID").Value,
                               WindowParentID = window.Attribute("WindowID_Parent").Value
                             }).ToList();
            int newWindowID = 0;
            foreach (WindowDetail win in this._windows)
            {
                newWindowID = this.NextID;
                this.UpdateID("Window", "WindowID", win.WindowID, newWindowID); // update all window.windowID to a new ID
                this.UpdateToolMenus("ToolMenu", "ToolMenuID", "WindowID", win.WindowID, newWindowID); // update the windowID within the toolmenu element
                this.UpdateParentID("WindowParameter", "WindowID", win.WindowID, newWindowID); // update all parameters with the new windowID 
                this.UpdateParentID("Window", "WindowID_Parent", win.WindowID, newWindowID); // update all windowid_parent with the new windowID 
            }

            this.UpdateParentID("Window", "DesktopID", this._originalDesktopID.ToString(), -1); // update the desktopid on each window with the new -1 id
        }

        /// <summary>
        /// update every element with the passed in parent id to the new parent id
        /// </summary>
        /// <param name="elementName">element name to search for</param>
        /// <param name="attributeName">attribute name to search for</param>
        /// <param name="oldID">old parent id</param>
        /// <param name="newID">new parent id</param>
        private void UpdateParentID(string elementName, string attributeName, string oldID, int newID)
        {
            // update all parent ids for the oldID that have the old window id as the parent id!
            try
            {
                List<XElement> updateElements = this._xDoc.Descendants(elementName).Where(node => node.Attribute(attributeName).Value == oldID).ToList();

                foreach (XElement element in updateElements)
                {
                    this.UpdateAttributeValue(element, attributeName, newID.ToString());
                }
            }
            catch
            {
            }
        }

        /// <summary>
        /// Update the main ID of the element
        /// </summary>
        /// <param name="elementName">element name</param>
        /// <param name="attributeName">attribute name</param>
        /// <param name="oldID">old id to search for element</param>
        /// <param name="newID">new element id</param>
        private void UpdateID(string elementName, string attributeName, string oldID, int newID)
        {
            var updateElement = this._xDoc.Descendants(elementName).Where(node => node.Attribute(attributeName).Value == oldID).Single();
            this.UpdateAttributeValue(updateElement, attributeName, newID.ToString());
        }

        /// <summary>
        /// Update the attribute value within the element passed to the method
        /// </summary>
        /// <param name="elementToUpdate">element to update</param>
        /// <param name="attributeName">attribute to target</param>
        /// <param name="value">new value for the attribute</param>
        private void UpdateAttributeValue(XElement elementToUpdate, string attributeName, string value)
        {
            elementToUpdate.SetAttributeValue(attributeName, value);
        }

        /// <summary>
        /// Update the tool menu IDs
        /// </summary>
        /// <param name="elementName">element name</param>
        /// <param name="firstAttributeName">first attribute name within the element</param>
        /// <param name="updateAttributeName">the attribute we would like to update</param>
        /// <param name="oldID">the old ID value used to search</param>
        /// <param name="newID">the new ID to be used</param>
        private void UpdateToolMenus(string elementName, string firstAttributeName, string updateAttributeName, string oldID, int newID)
        {
            // GP: Have to work with tool menus differently from the other elements, because events can have tool menus without the attributes we are looking for
            // had a few errors whith objects = null when trying lambda expressions to get the single element I was looking for so had to use a foreach and
            // check each one for the oldID.
            var elements = this._xDoc.Descendants(elementName).Where(node => node.FirstAttribute.Name == firstAttributeName).ToList();

            foreach (var element in elements.Where(element => element.Attribute(updateAttributeName).Value == oldID))
            {
                this.UpdateAttributeValue(element, updateAttributeName, newID.ToString());
            }
        }

        /// <summary>
        /// Process each window parameter
        /// </summary>
        private void ProcessWindowPrameters()
        {
            // get a list of window parameters
            this._windowParameters = (from windowParmeter in this._xDoc.Descendants("WindowParameter")
                                      where windowParmeter.Attribute("WindowParameterID").Value != "-1"
                                      select new WindowParameter
                                      {
                                         WindowID = windowParmeter.Attribute("WindowID").Value,
                                         WindowParameterID = windowParmeter.Attribute("WindowParameterID").Value
                                      }).ToList();

            foreach (WindowParameter winParam in this._windowParameters)
            {
                this.UpdateID("WindowParameter", "WindowParameterID", winParam.WindowParameterID, this.NextID);
            }
        }

        /// <summary>
        /// Process each window and desktop menu
        /// </summary>
        private void ProcessToolMenu()
        {
            // get all toolmenus 
            this._toolMenus = (from toolMenus in this._xDoc.Descendants("ToolMenu")
                               where toolMenus.FirstAttribute.Name == "ToolMenuID"
                               select new ToolMenu
                               {
                                   ToolMenuID = toolMenus.Attribute("ToolMenuID").Value,
                                   ToolMenuID_Parent = toolMenus.Attribute("ToolMenuID_Parent").Value,
                                   ToolMenuTypeID = toolMenus.Attribute("ToolMenuTypeID").Value
                               }).ToList();

            foreach (var toolMenu in this._toolMenus)
            {
                var toolMenuID = this.NextID;
                
                if (toolMenu.ToolMenuID == this._originalDesktopToolMenuID.ToString())
                {
                    this._newDesktopToolMenuID = toolMenuID;
                }
                else if (toolMenu.ToolMenuID == this._originalDesktopToolbarID.ToString())
                {
                    this._newDesktopToolbarID = toolMenuID;
                }

                this.UpdateToolMenus("ToolMenu", "ToolMenuID", "ToolMenuID", toolMenu.ToolMenuID, toolMenuID);
                this.UpdateToolMenus("ToolMenu", "ToolMenuID", "ToolMenuID_Parent", toolMenu.ToolMenuID, toolMenuID);
                this.UpdateParentID("Window", "ToolMenuID", toolMenu.ToolMenuID, toolMenuID);
            }
        }

        /// <summary>
        /// Get the current desktop details from the XDocument
        /// </summary>
        private void GetDesktopDetails()
        {
            // get a list of all desktop details
            var desktopDetail = (from desktops in this._xDoc.Descendants("Desktop")
                                 select desktops).ToList();

            this._originalDescription = desktopDetail[0].Attribute("Description").Value;
            int.TryParse(desktopDetail[0].Attribute("DesktopID").Value, out this._originalDesktopID);
            int.TryParse(desktopDetail[0].Attribute("ToolMenuID_Menu").Value, out this._originalDesktopToolMenuID);
            int.TryParse(desktopDetail[0].Attribute("ToolMenuID_Toolbar").Value, out this._originalDesktopToolbarID);
        }

        /// <summary>
        /// Update the XDocument with the new desktop details
        /// </summary>
        private void SetDesktopDetails()
        {
            // now update the desktop details
            var desktop = this._xDoc.Descendants("Desktop").Single();
            this.UpdateAttributeValue(desktop, "Description", this.newDesktopDescription);
            this.UpdateAttributeValue(desktop, "DesktopID", "-1");
            this.UpdateAttributeValue(desktop, "PolicyID", "-1");
            this.UpdateAttributeValue(desktop, "ToolMenuID_Menu", this._newDesktopToolMenuID.ToString());
            this.UpdateAttributeValue(desktop, "ToolMenuID_Toolbar", this._newDesktopToolbarID.ToString());
        }
    }
}
