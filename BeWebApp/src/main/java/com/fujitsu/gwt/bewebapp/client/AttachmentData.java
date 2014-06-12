package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.user.client.rpc.IsSerializable;

public class AttachmentData implements IsSerializable {
	String _id = "";
	String _name = "";
	String _desc = "";
	int _visibility = 2;
    String _readOnly = "";
	
	//Permission pending
	
	public AttachmentData(){
		
	}
	public AttachmentData(String id, String name, String desc){;
		_id = id;
		_name = name;
		_desc = desc;
	}
	public String getId(){
		return _id;
	}
	
	public String getName(){
		return _name;
	}
	
	public String getDescription(){
		return _desc;
	}
	
	public int getVisibility(){
        return _visibility;
    }
	
    public String getReadOnly(){
        return _readOnly;
    }
    
	public void setId(String id){
		_id = id;
	}
	
	public void setName(String name){
		_name = name;
	}
	
	public void setDescription(String desc){
		_desc = desc;
	}	
	
	public void setVisibility(int visibility){
	    _visibility = visibility;
	}
    
    public void setReadOnly(String readOnly){
        _readOnly = readOnly;
    }
}
