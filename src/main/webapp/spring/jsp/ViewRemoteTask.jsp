<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="java.util.Date"
%><%@page import="java.text.SimpleDateFormat"
%><%@page import="org.socialbiz.cog.TemplateRecord"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%!
    String pageTitle = "";
%><%
/*
Required parameters:

    1. userKey   : This is the id of an user
    2. url      : This parameter is url which is the unique key of the goal record

*/

    String userId = ar.reqParam("userKey");
    String url = ar.reqParam("url");

    UserProfile uProf = ar.getUserProfile();
    UserPage uPage = uProf.getUserPage();

    pageTitle = uProf.getName();

    SimpleDateFormat formatter  = new SimpleDateFormat ("MM/dd/yyyy");
    String bookKey=null;  //this is always NULL

    RemoteGoal currentTaskRecord = uPage.findRemoteGoal(url);
    if (currentTaskRecord==null) {
        throw new Exception("Unable to find the remote goal record");
    }

    List<HistoryRecord> histRecs = new Vector<HistoryRecord>();
    pageTitle = uProf.getName();





    Vector<NGBook> bookList =  new Vector<NGBook>();
    Vector<NGPageIndex> templates = new Vector<NGPageIndex>();
    for(TemplateRecord tr : uProf.getTemplateList()){
        String pageKey = tr.getPageKey();
        NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(pageKey);
        if (ngpi!=null){
            templates.add(ngpi);
            bookList.add(ngpi.getPage().getSite());
        }
    }
    NGPageIndex.sortInverseChronological(templates);

    NGPage localProject = NGPageIndex.getProjectByUpstreamLink(currentTaskRecord.getAccessURL());



%>

    <script src="<%=ar.baseURL%>jscript/jquery.dd.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="<%=ar.retPath%>css/dd.css" />

    <script type="text/javascript" language = "JavaScript">

        var flag=false;
        var emailflag=false;
        var taskNameRequired = '<fmt:message key="nugen.process.taskname.required.error.text"/>';
        var taskName = '<fmt:message key="nugen.process.taskname.textbox.text"/>';
        var emailadd='<fmt:message key="nugen.process.emailaddress.textbox.text"/>'

         function submitUpdatedTask(){
            var taskname =  document.getElementById("taskname_update");
            if(!(!taskname.value=='' || !taskname.value==null)){
                alert(taskNameRequired);
                    return false;
            }
            document.forms["updateTaskForm"].submit();
        }

        function createProject(){
            document.forms["projectform"].submit();
        }
        function inviteUser(bookId,pageId,emailId)
        {
            var uri='<%=ar.retPath%>'+"t/"+bookId+"/"+pageId+"/inviteUser.htm?emailId="+emailId;
            window.open(uri,TARGET="_parent");
        }

        function AddNewAssigne(){
            document.forms["assignTask"].submit();
        }

        var callbackprocess = {
           success: function(o) {
               var respText = o.responseText;
               var json = eval('(' + respText+')');
               if(json.msgType != "success"){
                   showErrorMessage("Result", json.msg , json.comments );
              }
           },
           failure: function(o) {
                   alert("callbackprocess Error:" +o.responseText);
           }
        }

    function removeAssigne(assigneeId){
        document.getElementById("remove").value="true";
        document.getElementById("removeAssignee").value=assigneeId;
        document.forms["assignTask"].submit();
    }

    function updateAssigneeVal(){
        emailflag=true;
    }


    function createSubTask(){
        var taskname =  document.getElementById("taskname");
        var assignto =  document.getElementById("assignto_SubTask");

        if(taskname.value=='' || taskname.value==null){
            alert(taskNameRequired);
                return false;
        }

        if(assignto.value==emailadd){
            document.getElementById("assignto_SubTask").value="";
        }
        document.forms["createSubTaskForm"].elements["assignto"].value = assignto.value;
        document.forms["createSubTaskForm"].submit();
    }

    function updateTaskVal(){
        flagSubTask=true;
    }

    function clearField(elementName) {
        var task=document.getElementById(elementName).value;
        if(task==taskName){
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

    function validatePercentage(){
        var percentage = document.getElementById("percentage").value;
        if(percentage==""){
            document.getElementById("percentage").value = 0;
        }else{
            var x = parseInt(percentage);
            var numericExpression = /^[0-9]+$/;
            if(percentage.match(numericExpression)) {
                if (isNaN(x) || x < 0 || x > 100) {
                    alert("Please enter correct percentage, a numeric value between 0 to 100");
                }
            } else {
                alert("Please enter correct percentage, a numeric value between 0 to 100");
            }
        }
    }
</script>

<body class="yui-skin-sam">

    <!-- Content Area Starts Here -->
    <div class="generalArea">

        <div id="TabbedPanels1" class="TabbedPanels">
            <div class="TabbedPanelsContentGroup">
                <div class="TabbedPanelsContent">
                    <table width="600">
                        <!-- ========================================================================= -->
                        <tr><td height="23px"></td></tr>
                        <tr>
                            <form action="<% ar.writeHtml(currentTaskRecord.getUserInterfaceURL());%>" method="get">
                            <td colspan="3" class="generalHeading">Remote Goal Status
                                &nbsp; &nbsp; &nbsp; &nbsp;
                                <input type="submit" value="Visit Project Site" class="inputBtn" /></td>
                            </form>                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"><fmt:message key="nugen.process.taskname.display.text"/>:</td>
                            <td style="width:20px;"></td>
                            <td class="textAreaGeneral">
                                <%ar.writeHtml(currentTaskRecord.getSynopsis());%>
                            </td>
                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader">Project:</td>
                            <td style="width:20px;"></td>
                            <td class="textAreaGeneral">
                                <a href="<%ar.writeHtml(currentTaskRecord.getProjectAccessURL());%>">
                                <%ar.writeHtml(currentTaskRecord.getProjectName());%></a> of 
                                <a href="<%ar.writeHtml(currentTaskRecord.getSiteAccessURL());%>">
                                <%ar.writeHtml(currentTaskRecord.getSiteName());%></a>
                            </td>
                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader">Assigned To:</td>
                            <td style="width:20px;"></td>
                            <td class="textAreaGeneral">
                                <%ar.writeHtml("unknown");%>
                            </td>
                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"><fmt:message key="nugen.process.priority.text"/></td>
                            <td style="width:20px;"></td>
                            <td>
                                <table>
                                    <tr>
                                        <td style="width:150px;" class="textAreaGeneral">
                                            <%ar.writeHtml(BaseRecord.getPriorityStr(currentTaskRecord.getPriority()));%>
                                         </td>
                                         <td style="width:45px;"></td>
                                         <td style="color:#000000"><b><fmt:message key="nugen.process.state.text"/></b></td>
                                        <td style="width:10px;"></td>
                                        <td class="textAreaGeneral">
                                            <img src="<%=ar.retPath%>assets/images/<%=BaseRecord.stateImg(currentTaskRecord.getState())%>">
                                            &nbsp; &nbsp;<%ar.writeHtml(BaseRecord.stateName(currentTaskRecord.getState()));%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"><fmt:message key="nugen.project.duedate.text"/></td>
                            <td style="width:20px;"></td>
                            <td>
                                <table>
                                    <tr>
                                        <td class="textAreaGeneral">
                                            <%=(currentTaskRecord.getDueDate()==0)?"":formatter.format(new Date(currentTaskRecord.getDueDate()))%>
                                        </td>
                                        <td style="width:17px;"></td>
                                        <td style="color:#000000"><b>Completed:</b></td>
                                        <td style="width:10px;"></td>
                                        <td class="textAreaGeneral">
                                            <%=currentTaskRecord.getPercentComplete()%>%
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"><fmt:message key="nugen.project.startdate.text"/></td>
                            <td style="width:20px;"></td>
                            <td>
                                <table>
                                    <tr>
                                        <td class="textAreaGeneral">
                                            <%=(currentTaskRecord.getStartDate()==0)?"":formatter.format(new Date(currentTaskRecord.getStartDate()))%>
                                        </td>
                                        <td style="width:17px;"></td>
                                        <td style="color:#000000"><b>End:</b></td>
                                        <td style="width:10px;"></td>
                                        <td class="textAreaGeneral">
                                            <%=(currentTaskRecord.getEndDate()==0)?"&nbsp;":formatter.format(new Date(currentTaskRecord.getEndDate()))%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                         <tr><td height="10px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.desc.text"/></td>
                            <td style="width:20px;"></td>
                            <td class="textAreaGeneral"><%ar.writeHtml(currentTaskRecord.getDescription());%></td>
                        </tr>
                        <tr><td height="25px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.status.text"/></td>
                            <td style="width:20px;"></td>
                            <td class="textAreaGeneral"><%ar.writeHtml(currentTaskRecord.getStatus());%></td>
                        </tr>
                        <tr><td height="30px"></td>
                        </tr>
                    </table>
                    <div class="generalArea">
                        <div class="generalHeading">Local Project</div>
                        <div class="generalContent">
                    <%
                        if(localProject!=null){
                    %>
                            <div>
                            A local project exists on this host:  <a href="<%=ar.retPath%><%=ar.getResourceURL(localProject, "projectActiveTasks.htm")%>">
                                <%ar.writeHtml(localProject.getFullName());%></a>
                            </div>
                    <%
                        }
                        else if(bookList!=null && bookList.size()<1){
                    %>
                            <div id="loginArea">
                                <span class="black">
                                    <fmt:message key="nugen.userhome.PermissionToCreateProject.text"/>
                                </span>
                            </div>
                    <%
                        }
                        else
                        {
                            String actionPath=ar.retPath+"t/createProjectFromRemoteGoal.form";
                    %>
                            <form name="projectform" action='<%=actionPath%>' method="post" autocomplete="off" >
                                <table width="600">
                                    <tr><td style="height:20px"></td></tr>
                                    <tr>
                                        <td class="gridTableColummHeader">Sub Project Name:</td>
                                        <td style="width:20px;"></td>
                                        <td>
                                            <input type="text" onblur="validateProjectField()" class="inputGeneral"
                                            name="projectname" id="projectname" value="<%ar.writeHtml(currentTaskRecord.getSynopsis());%>"
                                            onKeyup="updateVal();" onblur="addvalue();" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="gridTableColummHeader"></td>
                                        <td style="width:20px;"></td>
                                        <td width="396px">
                                            <b>Note:</b> From here you can create a new subproject.The subproject will be connected to this activity, and will be completed when the subproject process is completed.
                                        </td>
                                    </tr>
                                    <tr><td style="height:10px"></td></tr>
                                    <tr>
                                        <td class="gridTableColummHeader">Select Template:</td>
                                        <td style="width:20px;"></td>
                                        <td><Select class="selectGeneral" id="templateName" name="templateName">
                                            <option value="" selected>Select</option>
                                            <%
                                                for (NGPageIndex ngpi : templates){
                                                    %><option value="<%=ngpi.containerKey%>" ><%
                                                    ar.writeHtml(ngpi.containerName);
                                                    %></option><%
                                                }
                                            %>
                                                    </Select></td>
                                      </tr>
                                      <tr><td style="height:15px"></td></tr>
                                      <tr>
                                          <td class="gridTableColummHeader"><fmt:message key="nugen.userhome.Account"/></td>
                                          <td style="width:20px;"></td>
                                          <td><select class="selectGeneral" name="accountId" id="accountId">
                                            <%
                                                for (NGBook nGBook : bookList) {
                                                    String id =nGBook.getKey();
                                                    String bookName= nGBook.getName();
                                                    %><option value="<%=id%>"><%
                                                    ar.writeHtml(bookName);
                                                    %></option><%
                                                }
                                            %>
                                          </select></td>
                                     </tr>
                                     <tr><td style="height:15px"></td></tr>
                                     <tr>
                                         <td class="gridTableColummHeader" style="vertical-align:top"><fmt:message key="nugen.project.desc.text"/></td>
                                         <td style="width:20px;"></td>
                                         <td><textarea name="description" id="description" class="textAreaGeneral" rows="4" tabindex=7></textarea></td>
                                     </tr>
                                     <tr><td style="height:10px"></td></tr>
                                     <tr>
                                         <td class="gridTableColummHeader"></td>
                                         <td style="width:20px;"></td>
                                         <td>
                                             <input type="button" value="Create Sub Project" class="inputBtn" onclick="createProject();" />
                                             <input type="hidden" name="goUrl" value="<%ar.writeHtml(ar.getCompleteURL());%>" />
                                             <input type="hidden" id="parentProcessUrl" name="parentProcessUrl"
                                                value="XXX" />
                                         </td>

                                     </tr>
                                </table>
                            </form>
                  <%
                    }
                  %>
                        </div>
                        <!-- End here -->
                      </div>
                </div>
            </div>
            <script type="text/javascript">
                var TabbedPanels1 = new Spry.Widget.TabbedPanels("TabbedPanels1");
            </script>
        </div>
    </div>
</body>

<%
    if (ar.isMember()){
        SectionTask.plugInCalenderScript(out, "dueDate_update", "btn_update");
        SectionTask.plugInCalenderScript(out, "dueDate", "btn_dueDate");
        SectionTask.plugInCalenderScript(out, "startDate_update", "top_btn_startDate");
        SectionTask.plugInCalenderScript(out, "endDate_update", "top_btn_endDate");
    }
%><%!public void writeDate(AuthRequest ar, long date) throws Exception {
        if(date!=0){
            ar.write(new SimpleDateFormat("MM/dd/yyyy").format(new Date(date)));
        }else{
            ar.write(" -- ");
        }
    }%>
