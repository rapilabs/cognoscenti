package com.fujitsu.gwt.bewebapp.client.gantt;

import com.google.gwt.core.client.JavaScriptObject;


class GanttChartImpl {

	public native static JavaScriptObject create()/*-{
	 	var g = new $wnd.JSGantt.GanttChart('g',$doc.getElementById('GanttChartDIV'), 'day');
	 	$wnd.g = g;
    	return g;
	}-*/;

	public native static void addTaskItem(JavaScriptObject g, TaskItem taskItem) /*-{
		g.AddTaskItem(taskItem);
	}-*/;

	public native static void draw(JavaScriptObject g) /*-{
		g.Draw();
	}-*/;

	public native static void drawDependencies(JavaScriptObject g) /*-{
		g.DrawDependencies();
	}-*/;

	public native static void setShowResTrue(JavaScriptObject g) /*-{
		g.setShowRes(1); // Show/Hide Responsible (0/1)
	}-*/;
	public native static void setShowResFalse(JavaScriptObject g) /*-{
	g.setShowRes(0); // Show/Hide Responsible (0/1)
	}-*/;
	public native static void setShowDurTrue(JavaScriptObject g) /*-{
	g.setShowDur(1); // Show/Hide Duration (0/1)
	}-*/;
	public native static void setShowDurFalse(JavaScriptObject g) /*-{
	g.setShowDur(0); // Show/Hide Duration (0/1)
	}-*/;
	public native static void setShowCompTrue(JavaScriptObject g) /*-{
	g.setShowComp(1); // Show/Hide Duration (0/1)
	}-*/;
	public native static void setShowCompFalse(JavaScriptObject g) /*-{
	g.setShowComp(0); // Show/Hide Duration (0/1)
	}-*/;



/*
	public native void createPlotElement(int x,int y,int w,int h);

	public native void releasePlotElement();

	public native void addShape(Object shape);

	public native void clear();

	public native void drawPoint(int x,int y);*/

}
