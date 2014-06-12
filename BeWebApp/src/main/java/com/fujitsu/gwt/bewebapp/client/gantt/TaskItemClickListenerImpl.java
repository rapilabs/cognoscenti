package com.fujitsu.gwt.bewebapp.client.gantt;

import com.google.gwt.user.client.ui.ClickListener;
import com.google.gwt.user.client.ui.Widget;

class TaskItemClickListenerImpl implements ClickListener{

	GanttChartListener ganttChartListener;
	TaskItem taskItem;

	TaskItemClickListenerImpl(GanttChartListener ganttChartListener, TaskItem taskItem){
		this.ganttChartListener = ganttChartListener;
		this.taskItem = taskItem;
	}
	public void onClick(Widget sender) {
		ganttChartListener.onTaskItemClick(taskItem);

	}

}
