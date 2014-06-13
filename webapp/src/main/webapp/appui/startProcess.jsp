<%@page import="com.fujitsu.appui.common.CommonConstants"%>
<%@page import="com.fujitsu.appui.util.Utility"%>
<%@page import="com.fujitsu.appui.valueobject.AppUIProcDef"%>
<%@page import="com.fujitsu.iflow.model.workflow.Plan"%>

<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Date"%>

<%
    AppUIProcDef pDef = (AppUIProcDef) request.getAttribute(CommonConstants.REQUEST_ATTR_PLAN);
    Plan plan = pDef.getPlan();
    long planId = plan.getId();
    String name = pDef.getName();
    String desc = pDef.getDesc();
    
%>


<form id="startProcessForm">

<input type=hidden name="planId" value="<%=planId%>"/>

Process Name : <input type="planName" value="<%Utility.writeHtmlWithNBSPs(out,  name, true);%>"/>

<br/><br/>

Process Desc : <textarea name="planDesc"><%Utility.writeHtmlWithNBSPs(out,  desc, true);%></textarea>

<br/><br/>

<input type="button" name="startprocessbtn" value="Start Process" onClick="createProcess()">

</form>


<script>

function createProcess() {

    var formObject = document.getElementById('startProcessForm');
    YAHOO.util.Connect.setForm(formObject);
    var cObj = YAHOO.util.Connect.asyncRequest('POST', 'StartProcess.htm', callback);
}


var handleSuccess = function(o){
    var json = eval('(' + o.responseText+')');
    alert("Result: " + json.comments);
}

var handleFailure = function(o){
    alert("Error in submitting the request");
}

var callback =
{
  success:handleSuccess,
  failure: handleFailure
};

</script>