<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%/*
Required parameter:

    1. pageId   : This is the id of a Project and used to retrieve NGPage.
    2. taskId   : This parameter is id of a task and here it is used to get parent task detail (GoalRecord)
                  and to pass current task id value when submitted.


*/

    String pageId = ar.reqParam("pageId");
    String taskId = ar.reqParam("taskId");%>
<%!String pageTitle = "";
   String parentTaskName;%><%
    UserProfile uProf = ar.getUserProfile();
    NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);

    ar.setPageAccessLevels(ngp);
    NGBook ngb = ngp.getSite();
    pageTitle = ngp.getFullName();
    for(GoalRecord tr : ngp.getAllGoals()){
        if(taskId.equals(tr.getId().toString())){
    parentTaskName=tr.getSynopsis();
        }
    }
%>
<script type="text/javascript" language = "JavaScript">
    var flag=false;
    var emailflag=false;
    var taskNameRequired = '<fmt:message key="nugen.process.taskname.required.error.text"/>';
    var taskName = '<fmt:message key="nugen.process.taskname.textbox.text"/>';
    var emailadd='<fmt:message key="nugen.process.emailaddress.textbox.text"/>'

    function clearField(elementName) {
        var task=document.getElementById(elementName).value;
        if(task==taskName){
            document.getElementById(elementName).value="";
            document.getElementById(elementName).style.color="black";
        }
    }

    function clearFieldAssignee(elementName) {
        var assigneeEmail=document.getElementById(elementName).value;
        if(emailadd==assigneeEmail){
            document.getElementById(elementName).value="";
            document.getElementById(elementName).style.color="black";
        }
    }

    function defaultTaskValue(elementName) {
        var task=document.getElementById(elementName).value;
        if(task==""){
            flag=false;
            document.getElementById(elementName).value=taskName;
            document.getElementById(elementName).style.color = "gray";
        }
    }

    function defaultAssigneeValue(elementName) {
        var assigneeEmail=document.getElementById(elementName).value;
        if(assigneeEmail==""){
            emailflag=false;
            document.getElementById(elementName).value=emailadd;
            document.getElementById(elementName).style.color="gray";
        }
    }

    function updateTaskVal(){
        flag=true;
    }

    function updateAssigneeVal(){
        emailflag=true;
    }

    function submitTask(){
        var taskname =  document.getElementById("taskname");
        var assignto =  document.getElementById("assignto");

        if(!(flag && !taskname.value=='' || !taskname.value==null)){
            alert(taskNameRequired);
                return false;
        }

        if(assignto.value==emailadd){
            document.getElementById("assignto").value="";
        }
        document.forms["createSubTaskForm"].submit();
    }


    function reAssignTask(assignee){
        var assignee = prompt ("Re enter assignee",assignee);
    }


 /*function taskStatusCall(id){

    var url = "getTaskStatus.htm?statusId=" + id.value;
    alert(url);
    var req = initRequest();
        req.onreadystatechange = function() {
          if (req.readyState == 4) {
              if (req.status == 200) {
                 taskList = new Array();
                 taskList = req.responseText.split(",");
              }
          }};
     req.open("GET", url, true);
     req.send(null);

}*/
 </script>


<%
    if (!ar.isLoggedIn()) {
%>
    <div class="generalArea">
        <div class="generalContent">In order to see the tasks of
        the project, you need to be logged in, and you need to be an member of
        the project.
        </div>
    </div>
<%
    } else if (!ar.isMember()) {
%>
    <div class="generalArea">
        <div class="generalContent">In order to see the tasks of
        the project, you need to be a member. User '<% ar.getUserProfile().writeLink(ar); %>' is not a
        member. You can request membership, and if approved, you will then be
        able to access this information.<br />
        </div>
    </div>
<%
    } else {
%>

<!-- Content Area Starts Here -->
    <div class="generalArea">
        <div class="generalHeading">
        <!-- below does not work
        <fmt:message key="nugen.process.subtask.heading">
            <fmt:param value='<%ar.writeHtml(parentTaskName);%>'></fmt:param>
        </fmt:message>
        -->
        <br/>
        Creating Sub Task for the Task - <%ar.writeHtml(parentTaskName);%>
        </div>
    </div>
    <div class="generalContent"><!-- Tab Structure Starts Here -->
        <div id="container">
            <form name="createSubTaskForm" action="createSubTask.form" method="post">
                 <input type="hidden" name="go" id="go" value="<%ar.writeHtml(ar.getCompleteURL());%>"/>
                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td colspan="3">
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="100px;">
                                        <b><fmt:message key="nugen.process.subtask.parenttask"/></b>
                                    </td>
                                    <td></td>
                                    <td><%ar.writeHtml(parentTaskName);%></td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td width="100px;"><b><fmt:message key="nugen.process.taskname.display.text"/></b></td>
                                    <td></td>
                                    <td><input type="text" name="taskname" id="taskname" size="50" tabindex=1  value ='<fmt:message key="nugen.process.taskname.textbox.text"/>'  onKeyup="updateTaskVal();" onfocus="clearField('taskname');" onblur="defaultTaskValue('taskname');"/>&nbsp;
                                    <input type="button" value="Create SubTask" class="inputBtn" tabindex=3 onclick="submitTask();"/></td>
                                    <input type="hidden" name="taskId" value="<%ar.writeHtml(taskId);%>">
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td><b><fmt:message key="nugen.process.assignto.text"/></b></td>
                                    <td></td>
                                    <td><input type="text" class="wickEnabled" name="assignto" id="assignto" size="50" tabindex=2   value='<fmt:message key="nugen.process.emailaddress.textbox.text"/>' onkeydown="updateAssigneeVal();" autocomplete="off" onkeyup="autoComplete(event,this);"  onfocus="clearFieldAssignee('assignto');initsmartInputWindowVlaue('smartInputFloater','smartInputFloaterContent');" onblur="defaultAssigneeValue('assignto');"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td ></td>
                                    <td></td>
                                    <td>
                                        <div style="position:relative;text-align:left">
                                            <table  class="floater" style="position:absolute;top:0;left:0;background-color:#cecece;display:none;visibility:hidden"  id="smartInputFloater"  rules="none" cellpadding="0" cellspacing="0">
                                                <tr><td id="smartInputFloaterContent"  nowrap="nowrap" width="100%"></td></tr>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <div id="assignTask" style="display: inline">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr></tr>
                                    <tr><td>&nbsp;</td></tr>
                                    <tr>
                                        <td><b><fmt:message key="nugen.process.priority.text"/></b></td>
                                        <td></td>
                                        <td><select name="priority" tabindex=4>
                                            <option selected="selected" value ="0"><fmt:message key="nugen.process.priority.Normal"/></option>
                                            <option value="1"><fmt:message key="nugen.process.priority.Medium"/></option>
                                            <option value="2"><fmt:message key="nugen.process.priority.High"/></option>

                                        </select> &nbsp; &nbsp; &nbsp;
                                        <fmt:message key="nugen.project.duedate.text"/>&nbsp;
                                        <input type="text" size="10" name="dueDate" id="dueDate"  value="" readonly="1" tabindex=6/>
                                        <img src="<%=ar.retPath %>/jscalendar/img.gif" id="btn_dueDate" style="cursor: pointer;" title="Date selector"/>
                                        </td>
                                    </tr>
                                    <tr><td>&nbsp;</td></tr>
                                    <tr>
                                        <td width="100px;"><b><fmt:message key="nugen.project.desc.text"/></b></td>
                                        <td></td>
                                        <td><textarea name="description" id="description" cols="51" rows="5" tabindex=7></textarea></td>
                                    </tr>
                                    <tr><td>&nbsp;</td></tr>
                                    <tr>
                                    <td width="100px;"><b>(Optional)</b></td>
                                    <td></td>
                                    <td><img src="<%=ar.retPath %>/assets/images/ts_offered.gif" alt="accepted"/>
                                    <b><input type="checkbox" name="startActivity" id="startActivity" onclick="return selectAll('public')" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Start & Offer the Activity </b>
                                    </td>
                                </tr>
                               <tr><td style="height:20px"></td></tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
    </div>
<%
    }
%><%
    if (ar.isMember()){
        SectionTask.plugInCalenderScript(out, "dueDate", "btn_dueDate");
        SectionTask.plugInDurationCalcScript(out);
    }
    %>
