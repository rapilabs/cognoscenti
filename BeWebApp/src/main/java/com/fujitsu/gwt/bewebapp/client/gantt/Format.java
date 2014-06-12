package com.fujitsu.gwt.bewebapp.client.gantt;

import java.util.Date;

import com.google.gwt.i18n.client.DateTimeFormat;

public class Format {
	static DateTimeFormat dateTimeFormat = DateTimeFormat.getFormat("MM/dd/yyyy");
	public static String getStringDate(Date date){
		if(date == null){
			return "";
		} else{
			return dateTimeFormat.format(date);
		}
	}
	public static Date getDate(String date){
		return dateTimeFormat.parseStrict(date);
	}

}
