package com.fujitsu.gwt.bewebapp.client.gantt;

import java.util.ArrayList;
import java.util.Collection;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.dom.client.Element;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.ui.ClickListener;
import com.google.gwt.user.client.ui.Widget;

public class GanttChart extends Widget {
	public static final String GANTT_CHART_D_I_V = "GanttChartDIV";
	private static GanttChart instance = null;
	JavaScriptObject ganttChartJS;

	Collection<TaskItem> taskItems = new ArrayList<TaskItem>();
	private GanttChartListener ganttChartListener;

	GanttChart(Element element) {
		super();
        this.setElement(element);
	}
	  public static GanttChart create(){
		  if(instance == null){
			  JavaScriptObject jso = GanttChartImpl.create();
			  GanttChartImpl.setShowResTrue(jso);
			  GanttChartImpl.setShowDurTrue(jso);
			  GanttChartImpl.setShowCompTrue(jso);
			  instance = new GanttChart(DOM.getElementById(GANTT_CHART_D_I_V));
			  instance.ganttChartJS = jso;
		  }

		return instance;
	  }

		public final void addTaskItem(TaskItem taskItem) {
			taskItems.add(taskItem);
			GanttChartImpl.addTaskItem(ganttChartJS, taskItem);
		}

		public final void generate(){
			draw();
			drawDependencies();

			if(ganttChartListener != null){
				//add listener to new tasks
				for (TaskItem taskItem : taskItems) {
					ClickListener clickListener = new TaskItemClickListenerImpl(ganttChartListener,taskItem);
					taskItem.addListerner(clickListener);
				}
				//clear
				taskItems.clear();
			}

		}
		private final void draw(){
			GanttChartImpl.draw(ganttChartJS);
		}

		private final void drawDependencies(){
			GanttChartImpl.drawDependencies(ganttChartJS);
		}
		public void setGanttChartListener(GanttChartListener ganttChartListener) {
			this.ganttChartListener = ganttChartListener;
		}
		public GanttChartListener getGanttChartListener() {
			return ganttChartListener;
		}
}
