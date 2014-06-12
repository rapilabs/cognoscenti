package com.fujitsu.gwt.bewebapp.client.gantt;

import com.fujitsu.gwt.bewebapp.client.gantt.Format;
import com.fujitsu.gwt.bewebapp.client.gantt.TaskItem;
import com.google.gwt.i18n.client.Constants;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratorPanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.FlexTable.FlexCellFormatter;

public class TaskItemEditPanel extends Composite{

	boolean isCreate;
	TaskItem taskItem;

	// Parameters (pID, pName, pStart, pEnd, pColor, pLink, pMile, pRes, pComp, pGroup, pParent, pOpen)
	TextBox id = new TextBox(){{
		setEnabled(false);
	}};
	TextBox name = new TextBox();
	TextBox start = new TextBox();
	TextBox end = new TextBox();
	TextBox res = new TextBox();
	TextBox completion = new TextBox();
	CheckBox isGroup = new CheckBox();
	ListBox parent = new ListBox(false);
	ListBox depend = new ListBox(false);


	public TaskItemEditPanel(){
		isCreate = true;
		initialize();
	}

	public void clear() {
		id.setText("");
		name.setText("");
		start.setText("");
		end.setText("");
		res.setText("");
		completion.setText("");
		isGroup.setChecked(false);
		parent.setSelectedIndex(-1);
		depend.setSelectedIndex(-1);
	}

	public void setTask(TaskItem taskItem) {
		isCreate = false;
		this.taskItem = taskItem;

		id.setText(taskItem.getId());
		name.setText(taskItem.getName());
		start.setText(Format.getStringDate(taskItem.getStartDate()));
		//start.setText(taskItem.getStartDate());
		end.setText(Format.getStringDate(taskItem.getEndDate()));
		res.setText(taskItem.getResource());
		completion.setText(taskItem.getCompletionPercent()+"");
		isGroup.setChecked(taskItem.isGroup());
		//parent.setSelectedIndex(taskItem.getParentTaskId());
		//depend.setSelectedIndex(-1);
	}


	  public void initialize() {
	    // Create a table to layout the form options
	    FlexTable layout = new FlexTable();
	    layout.setCellSpacing(6);
	    FlexCellFormatter cellFormatter = layout.getFlexCellFormatter();

	    // Add a title to the form
	    layout.setHTML(0, 0, "Task details");
	    cellFormatter.setColSpan(0, 0, 2);
	    cellFormatter.setHorizontalAlignment(0, 0,
	        HasHorizontalAlignment.ALIGN_CENTER);

	    // Add some standard form options

	    layout.setHTML(1, 0, "id");
	    layout.setWidget(1, 1, id);
	    layout.setHTML(2, 0, "name");
	    layout.setWidget(2, 1, name);
	    layout.setHTML(3, 0, "start");
	    layout.setWidget(3, 1, start);
	    layout.setHTML(4, 0, "end");
	    layout.setWidget(4, 1, end);
	    layout.setHTML(5, 0, "responsible");
	    layout.setWidget(5, 1, res);
	    layout.setHTML(6, 0, "% completion");
	    layout.setWidget(6, 1, completion);
	    layout.setHTML(7, 0, "isGroup");
	    layout.setWidget(7, 1, isGroup);
	    layout.setHTML(8, 0, "parent");
	    layout.setWidget(8, 1, parent);
	    layout.setHTML(9, 0, "depend");
	    layout.setWidget(9, 1, depend);

	    // Wrap the content in a DecoratorPanel
	    DecoratorPanel decPanel = new DecoratorPanel();
	    decPanel.setWidget(layout);
	    initWidget(decPanel);
	  }

		public TextBox getIdField() {
			return id;
		}

		public TextBox getNameField() {
			return name;
		}

		public TextBox getStartField() {
			return start;
		}

		public TextBox getEndField() {
			return end;
		}

		public TextBox getResField() {
			return res;
		}

		public TextBox getCompletionField() {
			return completion;
		}

		public CheckBox getIsGroupField() {
			return isGroup;
		}

		public ListBox getParentField() {
			return parent;
		}

		public ListBox getDependField() {
			return depend;
		}

		public TaskItem getTaskItem() {
			return taskItem;
		}

}
