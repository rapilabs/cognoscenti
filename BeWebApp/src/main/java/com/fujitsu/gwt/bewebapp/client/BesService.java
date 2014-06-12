package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

/**
 * The async counterpart of <code>BesService</code>.
 */

@RemoteServiceRelativePath("besService")
public interface BesService extends RemoteService{

  String getBusinessEntity(String beid) throws IllegalArgumentException;

  String saveBusinessEntity(String beid, String data) throws IllegalArgumentException;

  String createBusinessEntity(String[] beMetaData, String data)
  		throws IllegalArgumentException;
  
  String getBusinessEntityList(String projetcId) throws IllegalArgumentException;

  String deleteBusinessEntity(String beid) throws IllegalArgumentException;

}