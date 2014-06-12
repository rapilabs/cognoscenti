package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.user.client.rpc.AsyncCallback;

/**
 * The async counterpart of <code>GreetingService</code>.
 */
public interface BesServiceAsync {
  void  getBusinessEntity(String beid, AsyncCallback<String> callback)
  		throws IllegalArgumentException;

  void  saveBusinessEntity(String beid, String data, AsyncCallback<String> callback)
  		throws IllegalArgumentException;

  void createBusinessEntity(String[] beMetaData, String data,  AsyncCallback<String> callback)
  		throws IllegalArgumentException;
 
  void  getBusinessEntityList(String input, AsyncCallback<String> callback)
      throws IllegalArgumentException;

  void  deleteBusinessEntity(String input, AsyncCallback<String> callback)
      throws IllegalArgumentException;
}
