package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("leafService")
public interface LeafService extends RemoteService
{
    LeafData[] getNotes(String pageId)throws IllegalArgumentException;
    LeafData getNote(String id, String pageId)throws IllegalArgumentException;
    LeafData saveNote(String pageId, LeafData leafData) throws IllegalArgumentException;
    LeafData createNote(String pageId, LeafData leafData) throws IllegalArgumentException;
    String removeNote(String pageId, String leadId) throws IllegalArgumentException;
    String isPageUpdated(String pageId) throws IllegalArgumentException;
    AttachmentData[]getAttachments(String pageId) throws IllegalArgumentException;
    AttachmentData getAttachment(String pageId, String aid) throws IllegalArgumentException;
    TaskData[] getTasks(String pageId)throws IllegalArgumentException;
}
