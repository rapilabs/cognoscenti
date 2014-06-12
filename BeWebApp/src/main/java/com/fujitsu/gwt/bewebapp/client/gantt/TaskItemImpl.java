package com.fujitsu.gwt.bewebapp.client.gantt;

import java.util.Date;


public class TaskItemImpl {

	//var taskItem = new JSGantt.TaskItem(1, 'Define Chart API', '', '', 'ff0000', 'http://help.com', 0, 'Brian', 0, 1, 0, 1)
    public native static TaskItem create(String pID, String pName, String pStart, String pEnd, String pColor, String pLink, int pMile, String pResponsible, int pComp, int pGroup, String pParent, int pOpen)/*-{
      var taskItem = new $wnd.JSGantt.TaskItem(pID, pName, pStart, pEnd, pColor, pLink, pMile, pResponsible, pComp, pGroup, pParent, pOpen);
      return taskItem;
	}-*/;
    public native static TaskItem create(String pID, String pName, String pStart, String pEnd, String pColor, String pLink, int pMile, String pResponsible, int pComp, int pGroup, String pParent, int pOpen, String pDependsOn)/*-{
    var taskItem = new $wnd.JSGantt.TaskItem(pID, pName, pStart, pEnd, pColor, pLink, pMile, pResponsible, pComp, pGroup, pParent, pOpen, pDependsOn);
    return taskItem;
	}-*/;

    // pID: (required) is a unique ID used to identify each row for parent functions and for setting dom id for hiding/showing
    public native static String getId(TaskItem taskItem)/*-{
    return taskItem.getID();
	}-*/;

    // pName: (required) is the task Label
    public native static String getName(TaskItem taskItem)/*-{
    return taskItem.getName();
	}-*/;

    public native static void setName(TaskItem taskItem, String name)/*-{
    //taskItem.vName = name;
    taskItem.setName(name);
	}-*/;

    // pStart: (required) the task start date, can enter empty date ('') for groups
    public native static double getStartDate(TaskItem taskItem)/*-{
	    var aDate = taskItem.getStart()
	    if(aDate != null){
	    	return aDate.getTime();
	    } else{
	    	return 0;
	    }
	}-*/;

    public native static void setStartDate(TaskItem taskItem, String start)/*-{
    taskItem.setStart(start);
	}-*/;

    // pEnd: (required) the task end date, can enter empty date ('') for groups
    public native static double getEndDate(TaskItem taskItem)/*-{
    	var aDate = taskItem.getEnd()
	    if(aDate != null){
	    	return aDate.getTime();
	    } else{
	    	return 0;
	    }
	}-*/;

    public native static void setEndDate(TaskItem taskItem, String end)/*-{
    taskItem.setEnd(end);
	}-*/;

    // pColor: (required) the html color for this task; e.g. '00ff00'
    public native static String getColor(TaskItem taskItem)/*-{
    return taskItem.getColor();
	}-*/;

    public native static void setColor(TaskItem taskItem, String color)/*-{
    taskItem.setColor(color);
	}-*/;

    // pLink: (optional) any http link navigated to when task bar is clicked.

    // pMile: UNUSED - in future will represent a milestone

    // pRes: (optional) resource name
    public native static String getResource(TaskItem taskItem)/*-{
    return taskItem.getResource();
	}-*/;

    public native static void setResource(TaskItem taskItem, String resource)/*-{
    taskItem.setResource(resource);
	}-*/;

    // pComp: (required) completion percent
    public native static int getCompletionPercent(TaskItem taskItem)/*-{
    return taskItem.getCompVal();
	}-*/;

    public native static void setCompletionPercent(TaskItem taskItem, int comp)/*-{
    taskItem.setCompVal(comp);
	}-*/;

    // pGroup: (optional) indicates whether this is a group(parent) - 0=NOT Parent; 1=IS Parent
    public native static int getGroup(TaskItem taskItem)/*-{
    return taskItem.getGroup();
	}-*/;

    public native static void setGroup(TaskItem taskItem, int group)/*-{
    taskItem.setGroup(group);
	}-*/;

    // pParent: (required) identifies a parent pID, this causes this task to be a child of identified task
    public native static String getParent(TaskItem taskItem)/*-{
    return taskItem.getParent();
	}-*/;

    public native static void setParent(TaskItem taskItem, String parent)/*-{
    taskItem.setParent(parent);
	}-*/;

    // pOpen: UNUSED - in future can be initially set to close folder when chart is first drawn


}
