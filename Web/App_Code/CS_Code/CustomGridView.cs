using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CustomGridView
{
	public class EmptyClickableGridView : GridView
	{
		#region Properties

		/// <summary>
		/// Enable or Disable generating an empty table if no data rows in source
		/// </summary>
		[
		Description("Enable or disable generating an empty table with headers if no data rows in source"),
		Category("Misc"),
		DefaultValue("true"),
		]
		public bool ShowEmptyTable
		{
			get
			{
				object o = ViewState["ShowEmptyTable"];
				return (o != null ? (bool)o : true);
			}
			set
			{
				ViewState["ShowEmptyTable"] = value;
			}
		}

		/// <summary>
		/// Get or Set Text to display in empty data row
		/// </summary>
		[
		Description("Text to display in empty data row"),
		Category("Misc"),
		DefaultValue(""),
		]
		public string EmptyTableRowText
		{
			get
			{
				object o = ViewState["EmptyTableRowText"];
				return (o != null ? o.ToString() : "");
			}
			set
			{
				ViewState["EmptyTableRowText"] = value;
			}
		}

		/// <summary>
		/// Get or Set TableRowMouseOverClientScripts
		/// </summary>
		[
		Description("onmouseover Client Scripts for TableRow"),
		Category("Misc"),
		DefaultValue(""),
		]
		public string TableRowMouseOverClientScripts
		{
			get
			{
				object o = ViewState["TableRowMouseOverClientScripts"];
				return (o != null ? o.ToString() : "");
			}
			set
			{
				ViewState["TableRowMouseOverClientScripts"] = value;
			}
		}

		public string RowCssClass
		{
			get
			{
				string rowClass = (string)ViewState["rowClass"];
				if (!string.IsNullOrEmpty(rowClass))
					return rowClass;
				else
					return string.Empty;
			}
			set
			{
				ViewState["rowClass"] = value;
			}
		}

		public string HoverRowCssClass
		{
			get
			{
				string hoverRowClass = (string)ViewState["hoverRowClass"];
				if (!string.IsNullOrEmpty(hoverRowClass))
					return hoverRowClass;
				else
					return string.Empty;
			}
			set
			{
				ViewState["hoverRowClass"] = value;
			}
		}

		/// <summary>
		/// Get or set whether a RowClick Event should occur when editing a row
		/// </summary>
		[
		Description("Should RowClick Event occur when editing a row"),
		Category("Misc"),
		DefaultValue("true"),
		]
		public bool RowClickEventWhenEditing
		{
			get
			{
				object o = ViewState["RowClickEventWhenEditing"];
				return (o != null ? (bool)o : true);
			}
			set
			{
				ViewState["RowClickEventWhenEditing"] = value;
			}
		}

		#endregion

		private static readonly object RowClickedEventKey = new object();
		public event GridViewRowClicked RowClicked;

		protected virtual void OnRowClicked(GridViewRowClickedEventArgs e)
		{
			if (RowClicked != null)
				RowClicked(this, e);
		}
		protected override void RaisePostBackEvent(string eventArgument)
		{


			if (eventArgument.StartsWith("on"))
			{
				int index = Int32.Parse(eventArgument.Split("_".ToCharArray())[1]);
				GridViewRowClickedEventArgs args = new GridViewRowClickedEventArgs(eventArgument.Split("_".ToCharArray())[0], Rows[index]);
				OnRowClicked(args);
			}
			else
			{
				base.RaisePostBackEvent(eventArgument);
			}
		}

		protected override void PrepareControlHierarchy()
		{
			base.PrepareControlHierarchy();

			for (int i = 0; i < Rows.Count; i++)
			{
				//for catch enter key event
				if (this.EditIndex == -1 || RowClickEventWhenEditing)
				{
					Rows[i].Attributes.Add("onkeyup", "if (event.keyCode == 13){" + Page.ClientScript.GetPostBackEventReference(this, "onenter_" + Rows[i].RowIndex.ToString()) + ";}");
					Rows[i].Attributes.Add("ondblclick", Page.ClientScript.GetPostBackEventReference(this, "ondblclick_" + Rows[i].RowIndex.ToString()));
					Rows[i].Attributes.Add("onclick", Page.ClientScript.GetPostBackEventReference(this, "onclick_" + Rows[i].RowIndex.ToString()));
					if (TableRowMouseOverClientScripts != string.Empty)
					{
						if (RowCssClass != string.Empty)
							Rows[i].Attributes.Add("onmouseout", "this.className='" + RowCssClass + "';" + TableRowMouseOverClientScripts + "('onmouseout',this);");
						if (HoverRowCssClass != string.Empty)
							Rows[i].Attributes.Add("onmouseover", "this.className='" + HoverRowCssClass + "';" + TableRowMouseOverClientScripts + "('onmouseover',this);");
					}
					else
					{
						if (RowCssClass != string.Empty)
							Rows[i].Attributes.Add("onmouseout", "this.className='" + RowCssClass + "';");
						if (HoverRowCssClass != string.Empty)
							Rows[i].Attributes.Add("onmouseover", "this.className='" + HoverRowCssClass + "';");
					}
				}
			}
		}

		protected override int CreateChildControls(System.Collections.IEnumerable dataSource, bool dataBinding)
		{
			int numRows = base.CreateChildControls(dataSource, dataBinding);

			//no data rows created, create empty table if enabled
			if (numRows == 0 && ShowEmptyTable)
			{
				//create table
				Table table = new Table();
				table.ID = this.ID;

				//create a new header row
				GridViewRow row = base.CreateRow(-1, -1, DataControlRowType.Header, DataControlRowState.Normal);

				//convert the exisiting columns into an array and initialize
				DataControlField[] fields = new DataControlField[this.Columns.Count];
				this.Columns.CopyTo(fields, 0);
				this.InitializeRow(row, fields);
				table.Rows.Add(row);

				//create the empty row
				row = new GridViewRow(-1, -1, DataControlRowType.DataRow, DataControlRowState.Normal);
				TableCell cell = new TableCell();
				cell.ColumnSpan = this.Columns.Count;
				cell.Width = Unit.Percentage(100);
				cell.Controls.Add(new LiteralControl(EmptyTableRowText));
				row.Cells.Add(cell);
				table.Rows.Add(row);

				this.Controls.Add(table);
			}

			return numRows;
		}
	}
	public class GridViewRowClickedEventArgs : EventArgs
	{
		private GridViewRow _row;
		private string _eventname;

		public GridViewRowClickedEventArgs(string eventName, GridViewRow aRow)
			: base()
		{
			_row = aRow;
			_eventname = eventName;
		}

		public GridViewRow Row
		{
			get { return _row; }
		}
		public string EventName
		{
			get { return _eventname; }
		}
	}

	public delegate void GridViewRowClicked(object sender, GridViewRowClickedEventArgs args);

}

