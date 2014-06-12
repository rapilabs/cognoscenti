package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.user.client.rpc.IsSerializable;


public class LeafData implements IsSerializable {

    private String id;
    private String pageId;
    private String subject;
    private String data;
    private int visibility;
    private boolean upstream = false;
    private String userId;
    private boolean isMember = false;
    private boolean dataLoaded = false;
    private String headerText = "subject  last edited by hello 2 days ago...";
    private String choice = "";
    private int editedBy = 0;
    private long effectiveDate = -1;
    private String pinPos;
    private boolean isDraft = false;
    public String[] allRoles = new String[0];
    public String[] checkedRoles = new String[0];

    public String getId()
    {
        return id;
    }
    public void setId(String id)
    {
        this.id = id;
    }

    public String getSubject()
    {
        return subject;
    }
    public void setSubject(String subject)
    {
        this.subject = subject;
    }

    public String getData()
    {
        return data;
    }
    public void setData(String data)
    {
        this.dataLoaded = true;
        this.data = data;
    }

    public int getVisibility()
    {
        return visibility;
    }

     public void setVisibility(int visibility)
     {
         this.visibility = visibility;
     }

     public String getPageId()
     {
         return pageId;
     }
     public void setPageId(String pageId)
     {
        this.pageId = pageId;
     }

     public String getUserId(){
         return userId;
     }

     public void setUserId(String userId){
         this.userId = userId;
     }

     public boolean isMember(){
         return isMember;
     }

     public  void setIsMember(boolean isMember){
         this.isMember = isMember;
     }

     public boolean isDataLoaded(){
         return dataLoaded;
     }

     public String getHeaderText(){
         return headerText;
     }
     public void setHeaderText(String headerText){
         this.headerText = headerText;
     }

     public String getChoice(){
         return choice;
     }

     public void setChoice(String choice){
         this.choice = choice;
     }

     public int getEditedBy(){
         return editedBy;
     }

     public void setEditedBy(int editedBy){
         this.editedBy = editedBy;
     }

     public long getEffectiveDate(){
         return effectiveDate;
     }

     public void setEffectiveDate(long ldate){
        effectiveDate = ldate;
     }

     public String getPinPosition(){
         return pinPos;
     }

     public void setPinPosition(String pinPos){
        this.pinPos = pinPos;
     }

     public boolean isDraft(){
         return isDraft;
     }
     public void setIsDraft(boolean isDraft){
         this.isDraft = isDraft;
     }

     public boolean isUpstream(){
         return upstream;
     }
     public void setUpstream(boolean ups){
         this.upstream = ups;
     }

}
