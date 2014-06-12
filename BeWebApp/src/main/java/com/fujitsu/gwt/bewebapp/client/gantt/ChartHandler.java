package com.fujitsu.gwt.bewebapp.client.gantt;

import java.util.Date;

import com.fujitsu.gwt.bewebapp.client.BeWebApp;
import com.fujitsu.gwt.bewebapp.client.LeafData;
import com.fujitsu.gwt.bewebapp.client.TaskData;
import com.fujitsu.gwt.bewebapp.client.gantt.GanttChartListener;
import com.fujitsu.gwt.bewebapp.client.gantt.Priority;
import com.fujitsu.gwt.bewebapp.client.gantt.Format;
import com.fujitsu.gwt.bewebapp.client.gantt.GanttChart;
import com.fujitsu.gwt.bewebapp.client.gantt.TaskItem;
import com.google.gwt.dom.client.Element;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.WindowResizeListener;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.ClickListener;
import com.google.gwt.user.client.ui.DialogBox;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.MouseListener;
import com.google.gwt.user.client.ui.Panel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

public class ChartHandler
{
    RootPanel rp;
    TaskData[] ngtasks;
    boolean isSample = false;
    final TaskItemEditPanel itemEditPanel = new TaskItemEditPanel();
    public ChartHandler(RootPanel grp) {
        rp = grp;
    }


    public  void initGanttChart() {
        Panel mainPanel = new HorizontalPanel();
        VerticalPanel v1Panel = new VerticalPanel();
        VerticalPanel v2Panel = new VerticalPanel();
        rp.add(mainPanel);

        final GanttChart ganttChart = GanttChart.create();

        GanttChartListener ganttChartListener = new GanttChartListener(){
            public void onTaskItemClick(TaskItem item) {
                itemEditPanel.setTask(item);
            }
        };

        ganttChart.setGanttChartListener(ganttChartListener);

        v1Panel.add(ganttChart);
        mainPanel.add(v1Panel);
        mainPanel.add(v2Panel);

        if(ganttChart !=null){
            if(isSample){
                generateSample(ganttChart);
            }else{
                generateTaskChart(ganttChart);
            }
            ganttChart.generate();

            Button saveButton = new Button("save");
            Button newButton = new Button("new");

            //v1Panel.add(newButton);

            v2Panel.setHorizontalAlignment(VerticalPanel.ALIGN_LEFT);
            v2Panel.add(itemEditPanel);
            //v2Panel.add(saveButton);


            // Create the dialog box
            final DialogBox dialogBox = createDialogBox();
            dialogBox.setAnimationEnabled(true);

            newButton.addClickHandler(new ClickHandler() {
                public void onClick(ClickEvent event) {
                    dialogBox.center();
                    dialogBox.show();
                    /*ganttChart.addTaskItem(TaskItem.create(11, "" + name.getText(), "2/20/2008", "2/20/2008", "ff00ff", "http://www.yahoo.com", 1, "Shlomy", 100, 0, 1, 1));
                    ganttChart.draw();
                    ganttChart.drawDependencies();*/
                }
             });

            saveButton.addClickHandler(new ClickHandler() {
                public void onClick(ClickEvent event) {
                    TaskItem taskItem = itemEditPanel.getTaskItem();
                    taskItem.setName(itemEditPanel.getNameField().getText());
                    taskItem.setCompletionPercent(Integer.parseInt(itemEditPanel.getCompletionField().getText()));
                    /*ganttChart.addTaskItem(TaskItem.create(11, "" + name.getText(), "2/20/2008", "2/20/2008", "ff00ff", "http://www.yahoo.com", 1, "Shlomy", 100, 0, 1, 1));*/
                    ganttChart.generate();
                }
             });

        }
    }

     private DialogBox createDialogBox() {
            // Add an image to the dialog
            TaskItemEditPanel createItemEditPanel = new TaskItemEditPanel();

            // Create a dialog box and set the caption text
            final DialogBox dialogBox = new DialogBox();
            dialogBox.ensureDebugId("cwDialogBox");
            dialogBox.setText("TEXT");

            // Create a table to layout the content
            VerticalPanel dialogContents = new VerticalPanel();
            dialogContents.setSpacing(4);
            dialogBox.setWidget(dialogContents);

            // Add some text to the top of the dialog
            HTML details = new HTML("toto");
            dialogContents.add(details);
            dialogContents.setCellHorizontalAlignment(details,
                HasHorizontalAlignment.ALIGN_CENTER);

            dialogContents.add(createItemEditPanel);
            dialogContents.setCellHorizontalAlignment(createItemEditPanel,
                HasHorizontalAlignment.ALIGN_CENTER);

            // Add a close button at the bottom of the dialog
            Button closeButton =  new Button("Close",
                new ClickHandler() {
                  public void onClick(ClickEvent event) {
                    dialogBox.hide();
                  }
            });
            dialogContents.add(closeButton);

            dialogContents.setCellHorizontalAlignment(closeButton,
                  HasHorizontalAlignment.ALIGN_RIGHT);


            // Return the dialog box
            return dialogBox;
          }

    private void generateTaskChart(GanttChart ganttChart){
        for (TaskData task : ngtasks){
            if(task.isGroup){
                ganttChart.addTaskItem(createTaskItem(task.id, task.name, (Date)null,
                        (Date)null,Priority.BLACK, task.processurl,0, task.assignee,
                        50, true, task.parentId, 1));
            }else{
                ganttChart.addTaskItem(createTaskItem(task.id, task.name, new Date(task.startdate),
                        new Date(task.enddate),Priority.BLACK, task.processurl,0, task.assignee,
                        50, false, task.parentId, 1));
            }
        }
    }

    private void generateSample(GanttChart ganttChart) {
        ganttChart.addTaskItem(createTaskItem("1", "Define Chart API", (Date)null, (Date)null, Priority.BLACK, "", 0, "Brian", 0, true, "0", 1));
        ganttChart.addTaskItem(createTaskItem("11", "Chart Object", Format.getDate("2/20/2008"), Format.getDate("2/20/2008"), "ff00ff", "http://www.yahoo.com", 1, "Shlomy", 100, false, "1", 1));
        ganttChart.addTaskItem(createTaskItem("12", "Task Objects", (Date)null, (Date)null, "00ff00", "", 0, "Shlomy", 40, true, "1", 1));
        ganttChart.addTaskItem(createTaskItem("121", "Constructor Proc", Format.getDate("2/21/2008"), Format.getDate("3/9/2008"), "00ffff", "http://www.yahoo.com", 0, "Brian T.", 60, false, "12", 1));
        ganttChart.addTaskItem(createTaskItem("122", "Task Variables", Format.getDate("3/6/2008"), Format.getDate("3/11/2008"), Priority.BLACK, "http://help.com", 0, "", 60, false, "12", 1,"121"));
        ganttChart.addTaskItem(createTaskItem("123", "Task Functions", Format.getDate("3/9/2008"), Format.getDate("3/28/2008"), Priority.BLACK, "http://help.com", 0, "Anyone", 10, false, "12", 1));
        ganttChart.addTaskItem(createTaskItem("2", "Create HTML Shell", Format.getDate("3/24/2008"), Format.getDate("3/25/2008"), "ffff00", "http://help.com", 0, "Brian", 20, false, "0", 1,"122"));
        ganttChart.addTaskItem(createTaskItem("3", "Code Javascript", (Date)null, (Date)null, Priority.BLACK, "http://help.com", 0, "Brian", 0, true, "0", 1));
        ganttChart.addTaskItem(createTaskItem("31", "Define Variables", Format.getDate("2/25/2008"), Format.getDate("3/17/2008"), "ff00ff", "http://help.com", 0, "Brian", 30, false, "3", 1));
        ganttChart.addTaskItem(createTaskItem("32", "Calculate Chart Size", Format.getDate("3/15/2008"), Format.getDate("3/24/2008"), "00ff00", "http://help.com", 0, "Shlomy", 40, false, "3", 1));
        ganttChart.addTaskItem(createTaskItem("33", "Draw Taks Items", (Date)null, (Date)null, "00ff00", "http://help.com", 0, "Someone", 40, true, "3", 1));
        ganttChart.addTaskItem(createTaskItem("332", "Task Label Table", Format.getDate("3/6/2008"), Format.getDate("3/11/2008"), Priority.ORANGE, "http://help.com", 0, "Brian", 60, false, "33", 1));
        ganttChart.addTaskItem(createTaskItem("333", "Task Scrolling Grid", Format.getDate("3/9/2008"), Format.getDate("3/29/2008"), Priority.ORANGE, "http://help.com", 0, "Brian", 60, false, "33", 1));
        ganttChart.addTaskItem(createTaskItem("34", "Draw Task Bars", (Date)null, (Date)null, "990000", "http://help.com", 0, "Anybody", 60, true, "3", 1));
        ganttChart.addTaskItem(createTaskItem("341", "Loop each Task", Format.getDate("3/26/2008"), Format.getDate("4/11/2008"), Priority.BLACK, "http://help.com", 0, "Brian", 60, false, "34", 1));
        ganttChart.addTaskItem(createTaskItem("342", "Calculate Start/Stop", Format.getDate("4/12/2008"), Format.getDate("5/18/2008"), "ff6666", "http://help.com", 0, "Brian", 60, false, "34", 1));
        ganttChart.addTaskItem(createTaskItem("343", "Draw Task Div", Format.getDate("5/13/2008"), Format.getDate("5/17/2008"), Priority.BLACK, "http://help.com", 0, "Brian", 60, false, "34", 1));
        ganttChart.addTaskItem(createTaskItem("344", "Draw Completion Div", Format.getDate("5/17/2008"), Format.getDate("6/04/2008"), Priority.BLACK, "http://help.com", 0, "Brian", 60, false, "34", 1));


    }
    private TaskItem createTaskItem(String pID, String pName, Date pStart, Date pEnd, String pColor, String pLink, int pMile, String pResponsible, int pComp, boolean isGroup, String pParent, int pOpen) {
        fillList(pID, pName, isGroup);
        return  TaskItem.create(pID, pName, pStart, pEnd, pColor, pLink, pMile, pResponsible, pComp, isGroup, pParent, pOpen);
    }
    private TaskItem createTaskItem(String pID, String pName, Date pStart, Date pEnd, String pColor, String pLink, int pMile, String pResponsible, int pComp, boolean isGroup, String pParent, int pOpen, String pDependsOn) {
        fillList(pID, pName, isGroup);
        return TaskItem.create(pID, pName, pStart, pEnd, pColor, pLink, pMile, pResponsible, pComp, isGroup, pParent, pOpen, pDependsOn);
    }

    private void fillList(String pID, String pName, boolean isGroup) {
        if(isGroup){
            itemEditPanel.getParentField().addItem(pName, pID);
        }
        itemEditPanel.getDependField().addItem(pName, pID);
    }

    public  void loadGanttChart(String prjId){

        if(prjId.equals("-1")){
            isSample = true;
            initGanttChart();
            return;
        }

        BeWebApp.leafService.getTasks(prjId, new AsyncCallback<TaskData[]>() {
        public void onFailure(Throwable caught) {
            Window.alert("Exception:" + caught);
        }
         public void onSuccess(TaskData[] tasks) {
             ngtasks = tasks;
             initGanttChart();
        }
      });
    }



}

