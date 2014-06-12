package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.user.client.rpc.IsSerializable;

/***
    pID: (required) is a unique ID used to identify each row for parent functions and for setting dom id for hiding/showing
    pName: (required) is the task Label
    pStart: (required) the task start date, can enter empty date ('') for groups
    pEnd: (required) the task end date, can enter empty date ('') for groups
    pColor: (required) the html color for this task; e.g. '00ff00'
    pLink: (optional) any http link navigated to when task bar is clicked.
    pMile: UNUSED - in future will represent a milestone
    pRes: (optional) resource name
    pComp: (required) completion percent
    pGroup: (optional) indicates whether this is a group(parent) - 0=NOT Parent; 1=IS Parent
    pParent: (required) identifies a parent pID, this causes this task to be a child of identified task
    pOpen: UNUSED - in future can be initially set to close folder when chart is first drawn
*/

public class TaskData implements IsSerializable{
    
    public String  processurl;
    public String id;
    public String  name;
    public String  desc;
    public String state;
    public String assignee;
    public String creator;
    public String status;
    public int priroty;
    public long duedate;
    public long startdate;
    public long enddate;
    public String parentId;
    public boolean isGroup;
}
