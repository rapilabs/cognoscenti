package com.fujitsu.gwt.bewebapp.client;


import com.google.gwt.user.client.rpc.AsyncCallback;

public interface LeafServiceAsync
{
    void getNotes(String pageId, AsyncCallback<LeafData[]> callback)
            throws IllegalArgumentException;;
    
    void getNote(String id, String pageId, AsyncCallback<LeafData> callback)throws IllegalArgumentException;
            
    void saveNote(String pageId, LeafData leafData, AsyncCallback<LeafData> callback)
        throws IllegalArgumentException;;
    
    void createNote(String pageId, LeafData leafData, AsyncCallback<LeafData> callback)
                throws IllegalArgumentException;
   
    void removeNote(String pageId, String leadId, AsyncCallback<String> callback) throws IllegalArgumentException;

    void isPageUpdated(String pageId, AsyncCallback<String> callback) throws IllegalArgumentException;
   
    void getAttachments(String pageId, AsyncCallback<AttachmentData[]> callback)
            throws IllegalArgumentException;
    
    void getAttachment(String pageId, String aid, AsyncCallback<AttachmentData> callback) 
            throws IllegalArgumentException;

    void getTasks(String pageId, AsyncCallback<TaskData[]> callback)
        throws IllegalArgumentException;;
    
}