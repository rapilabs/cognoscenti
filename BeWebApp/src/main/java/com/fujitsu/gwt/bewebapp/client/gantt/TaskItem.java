package com.fujitsu.gwt.bewebapp.client.gantt;

import java.util.Date;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.dom.client.Element;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Event;
import com.google.gwt.user.client.ui.ClickListener;
import com.google.gwt.user.client.ui.ClickListenerCollection;
import com.google.gwt.user.client.ui.MouseListener;
import com.google.gwt.user.client.ui.MouseListenerCollection;
import com.google.gwt.user.client.ui.SourcesClickEvents;
import com.google.gwt.user.client.ui.SourcesMouseEvents;
import com.google.gwt.user.client.ui.Widget;

public class TaskItem extends JavaScriptObject{

    protected TaskItem()
    {
        super();
    }


    public static TaskItem create(String pID, String pName, Date pStart, Date pEnd, String pColor, String pLink, int pMile, String pResponsible, int pComp, boolean isGroup, String pParent, int pOpen){
		int intGroup = getIntBoolean(isGroup);
    	return TaskItemImpl.create(pID, pName, Format.getStringDate(pStart), Format.getStringDate(pEnd), pColor, pLink, pMile, pResponsible, pComp, intGroup, pParent, pOpen);
    }
    public static TaskItem create(String pID, String pName, Date pStart, Date pEnd, String pColor, String pLink, int pMile, String pResponsible, int pComp, boolean isGroup, String pParent, int pOpen, String pDependsOn){
		int intGroup = getIntBoolean(isGroup);
    	return TaskItemImpl.create(pID, pName, Format.getStringDate(pStart), Format.getStringDate(pEnd), pColor, pLink, pMile, pResponsible, pComp, intGroup, pParent, pOpen, pDependsOn);
    }

    private final Element getElement(){
    	return DOM.getElementById("taskbar_" + getId());
    }
    private final TaskItemWidget getTaskItemWidget(){
    	TaskItemWidget taskItemWidget = new TaskItemWidget(getElement());
    	return taskItemWidget;
    }

    public final String getId(){
    	return TaskItemImpl.getId(this);
    }

    public final void addListerner(ClickListener listener){
    	TaskItemWidget widget = getTaskItemWidget();
    	widget.addClickListener(listener);

    }

    public final void addListerner(MouseListener listener){
    	TaskItemWidget widget = getTaskItemWidget();
    	widget.addMouseListener(listener);

    }

    public final void setName(String name) {
    	TaskItemImpl.setName(this, name);
	}

	public final String getName() {
		return TaskItemImpl.getName(this);
	}

	public final void setStartDate(Date startDate) {
		TaskItemImpl.setStartDate(this, Format.getStringDate(startDate));
	}

	public final Date getStartDate() {
		double date = TaskItemImpl.getStartDate(this);
		return new Date((long)date);
		//return Format.getDate(date);
	}

	public final void setEndDate(Date endDate) {
		TaskItemImpl.setEndDate(this, Format.getStringDate(endDate));
	}

	public final Date getEndDate() {
		double date = TaskItemImpl.getEndDate(this);
		return new Date((long)date);
		//return Format.getDate(date);
	}

	public final void setColor(String color) {
		TaskItemImpl.setColor(this, color);
	}

	public final String getColor() {
		return TaskItemImpl.getColor(this);
	}

	public final void setResource(String resource) {
		TaskItemImpl.setResource(this, resource);
	}

	public final String getResource() {
		return TaskItemImpl.getResource(this);
	}

	public final void setCompletionPercent(int completionPercent) {
		TaskItemImpl.setCompletionPercent(this,  completionPercent);
	}

	public final int getCompletionPercent() {
		return TaskItemImpl.getCompletionPercent(this);
	}

	public final void setGroup(boolean group) {
		int intGroup = getIntBoolean(group);
		TaskItemImpl.setGroup(this, intGroup);
	}

	public final boolean isGroup() {
		int intGroup = TaskItemImpl.getGroup(this);
		return getBoolean(intGroup);
	}

	public final void setParentTaskId(String parentTaskId) {
		TaskItemImpl.setParent(this,parentTaskId);
	}

	public final String getParentTaskId() {
		return TaskItemImpl.getParent(this);
	}

	class TaskItemWidget extends Widget implements SourcesClickEvents,SourcesMouseEvents {
    	  private ClickListenerCollection clickListeners;
    	  private MouseListenerCollection mouseListeners;


    	TaskItemWidget(Element element) {
    		   // verify that the element is actually an anchor
    	     setElement(element);
    	     sinkEvents(Event.ONCLICK);
    	     onAttach(); // existing element is already attached to DOM
   	   }


    	  public void addClickListener(ClickListener listener) {
    		    if (clickListeners == null) {
    		      clickListeners = new ClickListenerCollection();
    		      sinkEvents(Event.ONCLICK);
    		    }
    		    clickListeners.add(listener);
    		  }

    		  public void addMouseListener(MouseListener listener) {
    		    if (mouseListeners == null) {
    		      mouseListeners = new MouseListenerCollection();
    		      sinkEvents(Event.MOUSEEVENTS);
    		    }
    		    mouseListeners.add(listener);
    		  }



		public void removeClickListener(ClickListener listener) {
		    if (clickListeners != null) {
		        clickListeners.remove(listener);
		      }
		}


		public void removeMouseListener(MouseListener listener) {
		    if (mouseListeners != null) {
		        mouseListeners.remove(listener);
		      }
		}

		 @Override
		  public void onBrowserEvent(Event event) {
		    switch (event.getTypeInt()) {
		      case Event.ONCLICK:
		        if (clickListeners != null) {
		          clickListeners.fireClick(this);
		        }
		        break;

		      case Event.ONMOUSEDOWN:
		      case Event.ONMOUSEUP:
		      case Event.ONMOUSEMOVE:
		      case Event.ONMOUSEOVER:
		      case Event.ONMOUSEWHEEL:
		      case Event.ONMOUSEOUT:
		        if (mouseListeners != null) {
		          mouseListeners.fireMouseEvent(this, event);
		        }
		        break;


		    }
		  }
    }

	private static final boolean getBoolean(int intGroup){
		if(intGroup == 1){
			return true;
		}else{
			return false;
		}


	}
	private static final int getIntBoolean(boolean isGroup){
		int intGroup;
		if(isGroup){
			intGroup = 1;
		}else{
			intGroup = 0;
		}
		return intGroup;
	}
}
